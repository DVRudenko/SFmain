public class WorkcomChoosePriseController {
    public List<UserPrizeAssociation__c> userPrizeAssociationList { get; set; }
    public WorkCurrentUser currentUser { get; set; }
    public PrizeContext priseContext { get; set; }
    private List<Id> notificationUserIdList { get; private set; }

    public WorkcomChoosePriseController() {
        if (ApexPages.currentPage().getParameters().get('sfdc.userId') != null) {
            this.currentUser = new WorkCurrentUser(ApexPages.currentPage().getParameters().get('sfdc.userId'));
        } else {
            this.currentUser = new WorkCurrentUser(UserInfo.getUserId());
        }

        if (this.currentUser.isWorkcomUser) {
            Map<Id, String> recordsTypeMap = new Map<Id, String>();
            for (RecordTypeInfo info : Prize__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (info.isAvailable()) {
                    recordsTypeMap.put(info.getRecordTypeId(), info.getName());
                }
            }

            this.userPrizeAssociationList = getUserPrizeAssociationList();
            this.priseContext = new PrizeContext();

            Set<String> orderUsersEmails = new Set<String>();
            for (Workcom_Order_Admin__c emailOrder : [SELECT id, name FROM Workcom_Order_Admin__c WHERE businessType__c = :recordsTypeMap.values()]) { //Custom Settings
                orderUsersEmails.add(emailOrder.name);
            }

            List<User> orderUsers = [
                    SELECT id
                    FROM User
                    WHERE email IN :orderUsersEmails
            ];

            this.notificationUserIdList = new List<Id>();
            for (User user : orderUsers) {
                notificationUserIdList.add(user.id);
            }

        } else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Sorry, this user is not Work.com member. Please contact your SF administrator.'));
        }
    }

    /*******************************************************************************
   *  Name            : add()
   *  Summary         : action 'add' WorkcomChoosePrisePage.page
   *  CreatedDate     : 21/11/2017
   *  Parameters      : -
   *  Returns         : PageReference
   ******************************************************************************/
    public void add() {
        currentUser.refresh();

        try {

            priseContext.selectedPrizeId = ApexPages.currentPage().getParameters().get('prizeId');

            if (priseContext.getSelectedPrize().Cost__c > currentUser.endPoints) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.RU_0017_NotEnaPoints));
            } else if (priseContext.getSelectedPrize().Count__c != null && priseContext.getSelectedPrize().Count__c <= 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.RU_0063_ZeroCount));
            } else {
                UserPrizeAssociation__c userPrizeAssociationNew = new UserPrizeAssociation__c(
                        Prize__c = priseContext.selectedPrizeId, User__c = currentUser.userObj.Id
                );
                insert userPrizeAssociationNew;
                /* Note!!!
			        User points decreased through UserPriseAssociationTrigger, when  UserPrizeAssociation__c inserted
		        */

                if(priseContext.getSelectedPrize().Count__c != null) {
                    priseContext.getSelectedPrize().Count__c--;
                    update priseContext.getSelectedPrize();
                }

                userPrizeAssociationList = getUserPrizeAssociationList();
                currentUser.refresh();
                EmailGenerator.sendHtmlEmail(notificationUserIdList, 'Work.com: New Order', getNotificationMessage());
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.CONFIRM, Label.RU_0018_PrizeIsAddSucc));
            }

        } catch (System.DMLException eDML) {
            System.debug('Error: ' + eDML.getMessage());
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.FATAL, eDML.getMessage()));
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }

    /*******************************************************************************
    *  Name            : getUserPrizeAssociationList()
    *  Summary         : get UserPrizeAssociation__c List
    *  CreatedDate     : 21/11/2017
    *  Parameters      : -
    *  Returns         : List<UserPrizeAssociation__c>
    ******************************************************************************/
    private List<UserPrizeAssociation__c> getUserPrizeAssociationList() {
        return ([
                SELECT Name, CreatedDate, Prize__r.Name, Prize__r.ImageUrl__c, User__c
                FROM UserPrizeAssociation__c
                WHERE User__r.Id = :currentUser.userObj.Id
                ORDER BY CreatedDate DESC
        ]);
    }

    /*******************************************************************************
    *  Name            : getNotificationMessage()
    *  Summary         : get message about new order
    *  CreatedDate     : 21/11/2017
    *  Parameters      : userId - user id for notification
    *  Returns         : List<UserPrizeAssociation__c>
    ******************************************************************************/
    private String getNotificationMessage() {
        return '<p>' + Label.RU_0061_Order_Message_Employee + '<a href ="' +
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/' +
                currentUser.userObj.Id +
                '" > ' + currentUser.userObj.Name + ' </a> </p>' +
                '<p>' + Label.RU_0062_Order_Message_Prize + ': <a href ="' +
                URL.getSalesforceBaseUrl().toExternalForm() +
                '/' +
                priseContext.getSelectedPrize().Id + '" > ' +
                priseContext.getSelectedPrize().Name +
                ' </a> </p>';
    }

    public class PrizeContext {
        public Map<Id, Prize__c> costOfPrizeMap { get; private set; }
        public List<Prize__c> prizeList { get; private set; }
        public Id selectedPrizeId { get; set; }

        public PrizeContext() {
            Set<Id> recordsTypeSet = new Set<Id>();
            for (RecordTypeInfo info : Prize__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                if (info.isAvailable()) {
                    recordsTypeSet.add(info.getRecordTypeId());
                }
            }

            this.prizeList = new List<Prize__c>();
            this.costOfPrizeMap = new Map<Id, Prize__c>();
            for (Prize__c item : ([SELECT Name, ImageUrl__c, Cost__c, Count__c, Description__c FROM Prize__c WHERE RecordTypeId IN :recordsTypeSet ORDER BY Cost__c])) {
                costOfPrizeMap.put(item.Id, item);
                selectedPrizeId = item.Id;
                prizeList.add(item);
            }
        }

        public Prize__c getSelectedPrize() {
            if ( ! costOfPrizeMap.containsKey(selectedPrizeId)) {
                throw new NotHaveAvailablePrizeException('No found prize with id ' + selectedPrizeId);
            }
            return (Prize__c) costOfPrizeMap.get(selectedPrizeId);
        }
    }

    public class NotHaveAvailablePrizeException extends Exception {}
}