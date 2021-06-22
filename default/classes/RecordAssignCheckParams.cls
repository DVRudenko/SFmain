public class RecordAssignCheckParams {

    public Contact contact {get;set;}
    public Activity activity {get;set;}
    public ExpectedVolume expectedVolume {get;set;}

    public String recordStatus {get; set;}
    public String recordOwnerId {get; set;}
    public String decision {get; set;}
    public String currentGroup {get;set;}
    public String currentMember {get;set;}
    public String currentRegion {get;set;}
    public Boolean currentRegionIsFS {get;set;}
    public String hasVehicleFleet {get;set;}

    public String firstCallNumber {get;set;}
    public String callInitiatedPhoneNumber {get{return firstCallNumber == null ? contact.phone : firstCallNumber;}set;}

    public Map<Id, Lead> availableLeads {get; set;}
    public Map<Id, Opportunity> allOpportunitiesFromAccount {get; set;}
    public Map<Id, Opportunity> availableOpportunitiesFromAccount {get; set;}


    public class Contact{
        public String Id {get; set;}
        public String firstName {get; set;}
        public String middleName {get; set;}
        public String lastName {get; set;}
        public String phone {get; set;}
        public String extensionNumber {get; set;}
        public String phoneSecond {get; set;}
        public String position {get; set;}
        public String email {get; set;}
        public String emailSecond {get; set;}

        public String getPhoneWithExtensionNumber() {
            return phone == null || phone == '' ? null
                 : extensionNumber == null || extensionNumber == '' ? phone
                 : phone + '#' + extensionNumber;
        }
    }

    public class Activity{
        public String type {get; set;}
        public Boolean setCallBackForSecondPhone {get{return setCallBackForSecondPhone == null ? false : setCallBackForSecondPhone;} set;}
        public String disqualReason {get {return type == 'Disqualification' ? disqualReason : null;} set;}
        public String description {get; set;}
        public String ownerId {get; set;}
        public Date activityDate {get; set;}
        public String activityHour { get; set; }
        public String activityMinute { get; set; }
        public Datetime activityDateTime {
            get {
                if (activityDate != null) {
                    if (activityHour == null || activityHour == '') {
                        activityHour = Datetime.now().addMinutes(2).format('H');
                    }
                    if (activityMinute == null || activityMinute == '') {
                        activityMinute = Datetime.now().addMinutes(2).format('mm');
                    }
                    Date DT = activityDate ;
                    Time TM = Time.newInstance(Integer.valueOf(activityHour), Integer.valueOf(activityMinute), 0, 0);
                    //system.debug('DT : ' + DT);
                    //system.debug('TM : ' + TM);
                    DateTime DT_TM = DateTime.newInstance(DT, TM);
                    return DT_TM;
                } else {
                    return system.now().addMinutes(2);
                }
            }
            private set;
        }
        public Datetime callBackScheduledTime {get {return activityDateTime < system.now().addMinutes(1) ? system.now().addMinutes(1) : activityDateTime;} set;}
    }

    public class ExpectedVolume{
        public Boolean bigClient {
            get{
                Integer liters = (potential_Liters == null || potential_Liters == '' ? 0 : Integer.valueOf(potential_Liters));
                Integer rubles = (potential_Rub == null || potential_Rub == '' ? 0 : Integer.valueOf(potential_Rub));
                Integer cars = (potential_Cars == null || potential_Cars == '' ? 0 : Integer.valueOf(potential_Cars));
                Integer trucks = (potential_Trucks == null || potential_Trucks == '' ? 0 : Integer.valueOf(potential_Trucks));

                if(liters >= callCenterSpeedUp.BigClient_liters__c ||
                        rubles >= callCenterSpeedUp.BigClient_rubles__c ||
                        cars >= callCenterSpeedUp.BigClient_cars__c ||
                        trucks >= callCenterSpeedUp.BigClient_trucks__c){
                    return true;
                } else {
                    return false;
                }
            }
            set;
        }
        public String potential_Liters {get; set;}
        public String potential_Rub {get; set;}
        public String potential_Cars {get; set;}
        public String potential_Trucks {get; set;}
    }

    public static final Call_Center_Speed_Up__c callCenterSpeedUp = Call_Center_Speed_Up__c.getAll().get('RU');

    public String ownerPhoneCTI {
        get {
            List<User> ownerUser = [SELECT Id, Extension FROM User WHERE Id = :recordOwnerId];
            if (ownerUser.size() == 1) {
                return ownerUser.get(0).Extension;
            } else {
                return '';
            }
        }
        set;
    }


    public RecordAssignCheckParams(){
        recordStatus = 'Free';
        currentGroup = '';
        currentMember = '';
        recordOwnerId = '';
        decision = '';

        contact = new RecordAssignCheckParams.Contact();
        contact.id = '';
        contact.firstName = '';
        contact.middleName = '';
        contact.lastName = '';
        contact.phone = '';
        contact.phoneSecond = '';
        contact.position = '';
        contact.email = '';
        contact.emailSecond = '';

        expectedVolume = new RecordAssignCheckParams.ExpectedVolume();

        activity = new RecordAssignCheckParams.Activity();
        activity.type = '';
        activity.description = '';
        activity.activityDate = system.today();
        activity.ownerId = '';

        allOpportunitiesFromAccount = new Map<Id, Opportunity>();
        availableOpportunitiesFromAccount = new Map<Id, Opportunity>();
        availableLeads = new Map<Id, Lead>();

        currentRegionIsFS = false;
        hasVehicleFleet = 'Not defined';
    }
    
}
