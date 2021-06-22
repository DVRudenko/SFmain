/**
 * Created by Andrei.Moiseev on 05.04.2018.
 */

public class WorkcomBadgeReceivedProcessorRuGPC extends WorkcomBadgeReceivedProcessor implements WorkcomBadgeReceivedProcessorInterface {

    public WorkcomBadgeReceivedProcessorRuGPC() {
        this.LOCALE = 'ru_RU';
    }

    public void executeAfterInsert(List<WorkBadge> workBadgeList) {
        countedPoints(workBadgeList);
        checkComboBadge(workBadgeList);
    }

    public void executeBeforeInsert(List<WorkBadge> workBadgeList) {
        setDateOfAppointmentForWorkBadge(workBadgeList);
    }

    /*******************************************************************************
	*  Name            : checkComboBadge()
	*  Summary         : check consist badge combination and add 'combo' badge if it true
 	*  CreatedDate     : 24/11/2017
	*  Parameters      : newWorkBadgeList - List new WorkBadge
	*  Returns         : void
	******************************************************************************/
    public override void checkComboBadge(List<WorkBadge> workBadgeList) {
        System.debug('Run RU checkComboBadge');

        String comboMessage = Label.RU_0030_ComboBadge_Message;
        Id comboBadgeId = getComboBadgeId();
        Map<Id, WorkBadgeDefinition> keyBadge = getKeyBadge();
        System.debug('keyBadge: ' + keyBadge);

        // If not containse key Badge
        if (!containsKeyBadges(workBadgeList, keyBadge)) {
            return;
        }

        Map<Id, Set<Period>> usersPeriodMap = getUserPeriod(workBadgeList);

        if(usersPeriodMap.isEmpty()) {
            throw new FleetCorMonthException('Error: period is empty!');
        }

        System.debug('usersPeriodMap ' + usersPeriodMap);

        Map<Id, WorkThanks> workThanksMap = new Map<Id, WorkThanks>([
                SELECT GiverId
                FROM WorkThanks
        ]);

        System.debug('workThanksMap ' + workThanksMap);

        Map<Id, WorkBadge> workBadgeMap = new Map<Id, WorkBadge>([
                SELECT Message, DefinitionId, RecipientId, DateOfAppointment__c
                FROM WorkBadge
                WHERE RecipientId IN :usersPeriodMap.keySet()
        ]);

        System.debug('workBadgeMap ' + workBadgeMap);

        System.debug('Next 2');
        Map<Id, Map<Id, Set<Id>>> userIdPeriodBadgeMap =
                new Map<Id, Map<Id, Set<Id>>>(); // => Map<UserId, SetPeriod<SetBadge<BadgeId>>
        for (Id workBadgeId : workBadgeMap.keySet()) {
            WorkBadge wBadge = workBadgeMap.get(workBadgeId);
            Set<Period> periodItemSet = usersPeriodMap.get(wBadge.RecipientId);
            for (Period periodItem : periodItemSet) {
                if (wBadge.DateOfAppointment__c >= periodItem.StartDate &&
                        wBadge.DateOfAppointment__c <= periodItem.EndDate) {

                    if ( ! userIdPeriodBadgeMap.containsKey(wBadge.RecipientId) ) {
                        userIdPeriodBadgeMap.put(wBadge.RecipientId, new Map<Id, Set<Id>>());
                        userIdPeriodBadgeMap.get(wBadge.RecipientId).put(periodItem.Id,
                                new Set<Id>{wBadge.DefinitionId});
                    } else {
                        if ( ! userIdPeriodBadgeMap.get(wBadge.RecipientId).containsKey(periodItem.Id) ) {
                            userIdPeriodBadgeMap.get(wBadge.RecipientId).put(
                                    periodItem.Id,
                                    new Set<Id>{wBadge.DefinitionId}
                            );
                        }
                        userIdPeriodBadgeMap.get(wBadge.RecipientId).get(periodItem.Id).add(wBadge.DefinitionId);
                    }
                }
            }
        }

        Map<Integer, FeedItem> feedItemToInsertMap = new Map<Integer, FeedItem>();
        Map<Integer, WorkThanks> workThanksToInsertMap = new Map<Integer, WorkThanks>();
        Map<Integer, WorkBadge> workBadgeToInsertMap = new Map<Integer, WorkBadge>();

        Integer packetId = 1;
        for (WorkBadge item : workBadgeList) {
            if (keyBadge.containsKey(item.DefinitionId)) {
                Id userId = item.RecipientId;
                Map<Id, Set<Id>> periodIdBadgeIdSet = userIdPeriodBadgeMap.get(userId);
                System.debug('periodIdBadgeIdSet: ' + periodIdBadgeIdSet);
                if (periodIdBadgeIdSet != null) {
                    for (Id periodItemId : periodIdBadgeIdSet.keySet()) {
                        Set<Id> badgeDefinitionIdSet = periodIdBadgeIdSet.get(periodItemId);

                        if (badgeDefinitionIdSet != null &&
                                badgeDefinitionIdSet.containsAll(keyBadge.keySet()) &&
                                !badgeDefinitionIdSet.contains(comboBadgeId)) {

                            String dateFormat = DateTime.newInstance(
                                    item.DateOfAppointment__c.year(),
                                    item.DateOfAppointment__c.month(),
                                    item.DateOfAppointment__c.day()
                            ).format('MM/dd/yyyy');

                            String message =
                                    'Date=\'' + dateFormat.replace('/', '.') + '\' ' + comboMessage;

                            workThanksToInsertMap.put(packetId, new WorkThanks(Message = message,
                                    GiverId = workThanksMap.get(item.SourceId).GiverId));

                            workBadgeToInsertMap.put(packetId,
                                    new WorkBadge(DefinitionId = comboBadgeId, RecipientId = userId));

                            feedItemToInsertMap.put(packetId, new FeedItem(
                                    Body = message,
                                    Title = comboMessage,
                                    ParentId = userId,
                                    CreatedById = workThanksMap.get(item.SourceId).GiverId,
                                    Type = 'RypplePost')
                            );

                            // Mark, that we add combo badge in this period
                            badgeDefinitionIdSet.add(comboBadgeId);

                            packetId++;
                        }
                    }
                }
            }
        }

        System.debug('workBadgeMap: ' + workBadgeToInsertMap);
        System.debug('workThanksMap: ' + workThanksToInsertMap);
        System.debug('feedItemMap: ' + feedItemToInsertMap);

        // Insert new recognition
        insertWorkcomPackage(feedItemToInsertMap, workThanksToInsertMap, workBadgeToInsertMap);
    }

    /*******************************************************************************
	*  Name            : containsKeyBadges()
	*  Summary         : content check key badge in list WorkBadges
	*  CreatedDate     : 24/11/2017
	*  Parameters      : workBadges - List new WorkBadge, keyBadge - Map key badge
	*  Returns         : Boolean
	******************************************************************************/
    private static Boolean containsKeyBadges(List<WorkBadge> newWorkBadges, Map<Id, WorkBadgeDefinition> keyBadge) {
        for (WorkBadge item : newWorkBadges) {
            if (keyBadge.containsKey(item.DefinitionId)) {
                return true;
            }
        }
        return false;
    }

    /*******************************************************************************
    *  Name            : getKeyBadge()
    *  Summary         : get key badge detail
    *  CreatedDate     : 24/11/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    private static Map<Id, WorkBadgeDefinition>  getKeyBadge() {
        Map<String, Decimal> requiredKeyBadgeMap = getRequiredKeyBadgeMap();
        System.debug('requiredKeyBadgeMap: ' + requiredKeyBadgeMap);
        Map<Id, WorkBadgeDefinition> badgeDefinitionMap = new Map<Id, WorkBadgeDefinition>([
                SELECT Name, Points__c
                FROM WorkBadgeDefinition
        ]);

        Set<Id> receivedKeyBadgeId = new Set<Id>();
        for(Id badgeItemId : badgeDefinitionMap.keySet()) {
            WorkBadgeDefinition badgeItem = badgeDefinitionMap.get(badgeItemId);
            if(requiredKeyBadgeMap.containsKey(badgeItem.Name) && requiredKeyBadgeMap.get(badgeItem.Name) == badgeItem.Points__c) {
                receivedKeyBadgeId.add(badgeItem.Id);
            }
        }

        return new Map<Id, WorkBadgeDefinition>([
                SELECT Id
                FROM WorkBadgeDefinition
                WHERE Id =: receivedKeyBadgeId
        ]);
    }

    /*******************************************************************************
    *  Name            : getRequiredKeyBadgeMap()
    *  Summary         : read custom settings  Ru_Workcom_Combo_Badge_Bunch__c and create Map<BadgeName, Cost>
    *  CreatedDate     : 20/12/2017
    *  Parameters      : -
    *  Returns         : Map<String, Decimal>
    ******************************************************************************/
    private static Map<String, Decimal> getRequiredKeyBadgeMap() {
        Map<String, Decimal> requiredKeyBadgeMap = new Map<String, Decimal>();
        for (Ru_GPC_Workcom_Combo_Badge_Bunch__c keyBadgeItem : [SELECT id, name, points__c FROM Ru_GPC_Workcom_Combo_Badge_Bunch__c]) { //Custom Settings
            requiredKeyBadgeMap.put(keyBadgeItem.name, keyBadgeItem.points__c);
        }
        return requiredKeyBadgeMap;
    }
}