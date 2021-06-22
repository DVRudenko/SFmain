/**
 * Created by Andrei.Moiseev on 06.04.2018.
 */

public with sharing class WorkcomBadgeReceivedProcessorDe extends WorkcomBadgeReceivedProcessor implements WorkcomBadgeReceivedProcessorInterface {

    public WorkcomBadgeReceivedProcessorDe() {
        LOCALE = 'de_DE';
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
        System.debug('Run DE checkComboBadge');

        String comboMessage = Label.RU_0030_ComboBadge_Message;
        Id comboBadgeId = getComboBadgeId();
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
        Map<Id, Decimal> usersPoints = new Map<Id, Decimal>();

        Integer packetId = 1;
        for (WorkBadge item : workBadgeList) {
                Id userId = item.RecipientId;
                Map<Id, Set<Id>> periodIdBadgeIdSet = userIdPeriodBadgeMap.get(userId);
                if (periodIdBadgeIdSet != null) {
                    for (Id periodItemId : periodIdBadgeIdSet.keySet()) {
                        Set<Id> badgeDefinitionIdSet = periodIdBadgeIdSet.get(periodItemId);

                        if (badgeDefinitionIdSet != null &&
                            badgeDefinitionIdSet.size() == 4 &&
                            ! badgeDefinitionIdSet.contains(comboBadgeId) ) {

                            String dateFormat = DateTime.newInstance(
                                    item.DateOfAppointment__c.year(),
                                    item.DateOfAppointment__c.month(),
                                    item.DateOfAppointment__c.day()
                            ).format('MM/dd/yyyy');

                            String message =
                                    'Date=\'' + dateFormat.replace('/', '.') + '\' ' + comboMessage;

                            Decimal sumPoints = sumBadgePoints(badgeDefinitionIdSet);
                            if (usersPoints.containsKey(userId)) {
                                usersPoints.put(userId, usersPoints.get(userId) + sumPoints);
                            } else {
                                usersPoints.put(userId, sumPoints);
                            }

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
        // Insert new recognition
        insertWorkcomPackage(feedItemToInsertMap, workThanksToInsertMap, workBadgeToInsertMap);

        // update points for users
        updateUserPoints(usersPoints);

    }

    /*******************************************************************************
    *  Name            : sumBadgePoints()
    *  Summary         : calculate points of badges
    *  CreatedDate     : 27/06/2018
    *  Parameters      : badgeDefinitionIdSet - List WorkBadgeDefinition for calculate their points
    *  Returns         : Decimal
    ******************************************************************************/
    private static Decimal sumBadgePoints(Set<Id> badgeDefinitionIdSet) {
        Decimal sum = 0;
        for (WorkBadgeDefinition badge : [SELECT Points__c FROM WorkBadgeDefinition WHERE Id IN:badgeDefinitionIdSet LIMIT 100]) {
            sum += badge.Points__c;
        }
        return sum;
    }

    /*******************************************************************************
    *  Name            : updateUserPoints()
    *  Summary         : update points by Users
    *  CreatedDate     : 27/06/2018
    *  Parameters      : userPoints - map User Id and Points
    *  Returns         : void
    ******************************************************************************/
    private static void updateUserPoints(Map<Id, Decimal> userPoints) {
        List<User> userListUpdate = new List<User>();
        for (User user : [SELECT Id, Points__c, Earned_Points__c FROM User WHERE Id IN: userPoints.keySet()]) {
            user.Points__c += userPoints.get(user.Id);
            user.Earned_Points__c += userPoints.get(user.Id);
            userListUpdate.add(user);
        }
        update userListUpdate;
    }
}