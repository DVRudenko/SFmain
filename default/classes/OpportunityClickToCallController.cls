public with sharing class OpportunityClickToCallController {
    private User currentUser {get; set;}
    public String contactPhone {get; set;}
    public String userPhone {get; set;}
    //dialoga
    public static final String DIALOGA_USERNAME = 'd184603c-5b97-487d-affc-01b81902f75c';
    public static final String DIALOGA_PASSWORD = '2a4dd301-2e4c-45ef-b585-4a02d4547322';
    public static final String DIALOGA_ENDPOINT = 'https://api.parthenon.io/api/widget/d184603c-5b97-487d-affc-01b81902f75c/t-call/';
    public Boolean displayDialogaSection {get; set;}

    public OpportunityClickToCallController(ApexPages.StandardController controller) {}

    public void init() {
        String opportunityId = ApexPages.currentPage().getParameters().get('id');
        List<OpportunityContactRole> contactRolesList = [
        		SELECT Contact.Phone
        		FROM OpportunityContactRole
        		WHERE OpportunityId = :opportunityId AND 
        			  IsPrimary = TRUE AND 
        			  Contact.Phone != NULL
        		LIMIT 1];
        if (contactRolesList.isEmpty()) {
        	this.displayDialogaSection = false;
        	return;
        } else {
        	this.contactPhone = contactRolesList.get(0).Contact.Phone;
        }

        this.currentUser = [
                    SELECT UserRole.Name, Profile.Name, Phone
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];
        this.userPhone = this.currentUser.Phone;

        List<GroupMember> groupMembersList = [
                SELECT UserOrGroupId 
                FROM GroupMember 
                WHERE Group.Name = 'DialogaUsers'
                LIMIT 10000];
        Set<Id> groupMemberIdsSet = new Set<Id>();
        for (GroupMember gm : groupMembersList) {
            groupMemberIdsSet.add(gm.UserOrGroupId);
        }
        if (groupMemberIdsSet.contains(UserInfo.getUserId())) {
            displayDialogaSection = true;
        } else {
            displayDialogaSection = false;
        }
    }

    public void doDialogaCall() {
        try {
            if (this.userPhone == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please add phone to User profile.'));
                return;
            }

            Blob headerValue = Blob.valueOf(DIALOGA_USERNAME + ':' + DIALOGA_PASSWORD);
            String authorizationHeader = 'BASIC ' +
            EncodingUtil.base64Encode(headerValue);
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = DIALOGA_ENDPOINT;
            request.setEndpoint(endpoint);                
            request.setMethod('POST');
            String dialogaSenderPhone = (this.userPhone != null || this.userPhone.contains('+')) ? this.userPhone.replace('+','00') : this.userPhone;
            String dialogaRecipientPhone = (this.contactPhone != null || this.contactPhone.contains('+')) ? this.contactPhone.replace('+','00') : this.contactPhone;
            String requestBody = '' +
                'session=7' + 
                '&Campaign=127' +
                '&Client=FLEETCOR0509' + 
                '&Phone1=' + dialogaSenderPhone +
                '&Phone2=' + dialogaRecipientPhone +
                '&propagate=4991114955728';
            request.setBody(requestBody);
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setHeader('Authorization', authorizationHeader);
            HttpResponse response = h.send(request);
            if (response.getStatusCode() == 200) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Call started. Please pick up the User phone and wait for client.'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please try again later.'));
                System.debug('DEBUG: response === ' + response);
                System.debug('DEBUG: response.Body === ' + response.getBody());
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Internal error. Please contact your administrator.'));
            System.debug('DEBUG: Exception === ' + e.getMessage());
        }
    }
}