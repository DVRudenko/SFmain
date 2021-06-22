/**
 * Created by Andrei.Moiseev on 05.04.2018.
 */

public abstract class WorkcomBadgeReceivedProcessor {
    protected String LOCALE;
    protected List<WorkBadge> workBadgesList = new List<WorkBadge>();

    public virtual void setWorkBadge(WorkBadge workBadge) {
        this.workBadgesList.add(workBadge);
    }

    /*******************************************************************************
	*  Name            : countedPoints()
	*  Summary         : counted users points
	*  CreatedDate     : 24/02/2017
	*  Parameters      : workBadgeList - List new WorkBadge
	*  Returns         : void
	******************************************************************************/
    protected virtual void countedPoints(List<WorkBadge> workBadgeList) {
        Map<Id, WorkBadgeDefinition> workBadgeDefinitionMap = getWorkBadgeDefinitionMap(workBadgeList);
        Map<Id, User> usersMap = getUserMap(workBadgeList);
        Map<Id, User> userForUpdateMap = new Map<Id, User>();

        for (WorkBadge wBadge : workBadgeList) {
            User recipientUser;

            if (userForUpdateMap.containsKey(wBadge.RecipientId)) {
                recipientUser = userForUpdateMap.get(wBadge.RecipientId);
            } else {
                recipientUser = usersMap.get(wBadge.RecipientId);
            }

            WorkBadgeDefinition wBadgeDefinition = workBadgeDefinitionMap.get(wBadge.DefinitionId);

            if (recipientUser.Points__c == null || recipientUser.Earned_Points__c == null) {
                throw new WorkcomUserPointsDoesNotInitException('Error: Init users points Points__c and Earned_Points__c');
            }

            if (wBadgeDefinition.If_balance_zero__c == true && recipientUser.Points__c <= 0){
                continue;
            }

            recipientUser.Points__c += wBadgeDefinition.Points__c;
            recipientUser.Earned_Points__c += wBadgeDefinition.Points__c;
            userForUpdateMap.put(recipientUser.Id, recipientUser);
        }
        update userForUpdateMap.values();
    }

    /*******************************************************************************
    *  Name            : setDateOfAppointmentForWorkBadge()
    *  Summary         : set date of appointment to workBadge
    *  CreatedDate     : 24/02/2017
    *  Parameters      : workBadgeList - List new WorkBadge
    *  Returns         : void
    ******************************************************************************/
    protected virtual void setDateOfAppointmentForWorkBadge(List<WorkBadge> workBadgeList) {
        Set<Id> thanksIdSet = new Set<Id>();
        for (WorkBadge item : workBadgeList) {
            thanksIdSet.add(item.SourceId);
        }

        Map<Id, WorkThanks> thanksMap = new Map<Id, WorkThanks>([
                SELECT DateOfAppointment__c
                FROM WorkThanks
                WHERE Id IN :thanksIdSet
        ]);

        for (WorkBadge item : workBadgeList) {
            item.DateOfAppointment__c = thanksMap.get(item.SourceId).DateOfAppointment__c;
        }
    }

    protected abstract void checkComboBadge(List<WorkBadge> workBadgeList);


    /*******************************************************************************
	*  Name            : getUserPeriod()
	*  Summary         : formed container by userId and set. Set containst periods
						 belonging to userId and inserted WorkBadge
	*  CreatedDate     : 24/11/2017
	*  Parameters      : newWorkBadgeList - List new WorkBadge
	*  Returns         : Map<Id, Set<Period>>
	******************************************************************************/
    protected Map<Id, Set<Period>> getUserPeriod(List<WorkBadge> newWorkBadgeList) {
        List<Date> maxMinDates = new List<Date>();
        findMaxMinDateInList(maxMinDates, newWorkBadgeList);
        Date minDate = maxMinDates.get(0);
        Date maxDate = maxMinDates.get(1);

        Map<Id, Period> periodMap = new Map<Id, Period>([
                SELECT StartDate, EndDate
                FROM Period
                WHERE Type = 'Month'
                AND (
                        (StartDate <= :minDate AND EndDate >= :minDate)
                        OR (StartDate <= :maxDate AND EndDate >= :maxDate)
                        OR (StartDate >= :minDate AND EndDate <= :maxDate)
                )
        ]);

        Map<Id, Set<Period>> usersPeriodMap = new Map<Id, Set<Period>>(); // => Map<UserId, Set<Period>>
        for (WorkBadge item : newWorkBadgeList) {
            Id userId = item.RecipientId;
            Date dateInput = item.DateOfAppointment__c;
            for (Id periodId : periodMap.keySet()) {
                Period periodItem = periodMap.get(periodId);
                if (periodItem.StartDate <= dateInput && periodItem.EndDate >= dateInput) {
                    if (!usersPeriodMap.containsKey(userId)) {
                        usersPeriodMap.put(userId, new Set<Period>{periodItem});
                    } else {
                        usersPeriodMap.get(userId).add(periodItem);
                    }
                }
            }
        }
        return usersPeriodMap;
    }

    /*******************************************************************************
	*  Name            : findMaxMinDateInList()
	*  Summary         : find for the minimum and maximum insertion date for the WorkBadge
	*  CreatedDate     : 24/11/2017
	*  Parameters      : maxMinDates - List for min and max date , workBadges - List new WorkBadge
	*  Returns         : void
	******************************************************************************/
    protected void findMaxMinDateInList(List<Date> maxMinDates, List<WorkBadge> workBadges) {
        maxMinDates.clear();
        if (workBadges.isEmpty()) {
            throw new FleetCorMonthException('Error: insert badge not found');
        }

        List<WorkBadgeWrapper> workBadgeWrap = new List<WorkBadgeWrapper>();
        for (WorkBadge item : workBadges) {
            workBadgeWrap.add(new WorkBadgeWrapper(item));
        }

        if (workBadgeWrap.size() > 1) {
            workBadgeWrap.sort();
            maxMinDates.add(workBadgeWrap.get(0).wBadge.DateOfAppointment__c);
            maxMinDates.add(workBadgeWrap.get(workBadges.size() - 1).wBadge.DateOfAppointment__c);
        } else {
            maxMinDates.add(workBadgeWrap.get(0).wBadge.DateOfAppointment__c);
            maxMinDates.add(workBadgeWrap.get(0).wBadge.DateOfAppointment__c);
        }
    }


    /*******************************************************************************
    *  Name            : getWorkBadgeDefinitionMap()
    *  Summary         : get badges by WorkBadges
    *  CreatedDate     : 24/11/2017
    *  Parameters      : workBadgeList - List new WorkBadge
    *  Returns         : Map<Id, WorkBadgeDefinition>
    ******************************************************************************/
    private static Map<Id, WorkBadgeDefinition> getWorkBadgeDefinitionMap(List<WorkBadge> workBadgeList) {
        Set<Id> badgeDefinitionIdSet = new Set<Id>();

        for (WorkBadge item : workBadgeList) {
            badgeDefinitionIdSet.add(item.DefinitionId);
        }

        return new Map<Id, WorkBadgeDefinition>([
                SELECT Points__c, If_balance_zero__c
                FROM WorkBadgeDefinition
                WHERE Id IN :badgeDefinitionIdSet
        ]);
    }

    /*******************************************************************************
	*  Name            : getUserMap()
	*  Summary         : get users by WorkBadges
	*  CreatedDate     : 24/11/2017
	*  Parameters      : workBadgeList - List new WorkBadge
	*  Returns         : Map<Id, User>
	******************************************************************************/
    protected Map<Id, User> getUserMap(List<WorkBadge> workBadgeList) {
        Set<Id> recipientUserIdSet = new Set<Id>();

        for (WorkBadge item : workBadgeList) {
            recipientUserIdSet.add(item.RecipientId);
        }

        return new Map<Id, User>([
                SELECT Points__c, Earned_Points__c
                FROM User
                WHERE Id IN :recipientUserIdSet
        ]);
    }

    protected Id getComboBadgeId() {
        List<Ru_Workcom_Combo_Badge_Settings__c> listSettings = ([
                SELECT id, name, location__c, badgeName__c
                FROM Ru_Workcom_Combo_Badge_Settings__c
                WHERE location__c = :LOCALE
        ]);

        if(listSettings.isEmpty()) {
            throw new WorkcomComboBadgeNotExistsException('Settings for Combo badge does not exits for LOCALE ' + LOCALE);
        }

        List<WorkBadgeDefinition> comboBadgeList = ([
                SELECT Id
                FROM WorkBadgeDefinition
                WHERE Name =: listSettings.get(0).badgeName__c
                LIMIT 1
        ]);

        if (comboBadgeList.isEmpty()) {
            throw new WorkcomComboBadgeNotExistsException('Combo badge does not exits for LOCALE ' + LOCALE);
        }

        return comboBadgeList.get(0).Id;
    }

    /*******************************************************************************
	*  Name            : insertWorkcomPackage()
	*  Summary         : insert new Thanks recognition with feed.
	*  CreatedDate     : 24/11/2017
	*  Parameters      : feedItems - map FeedItem , workThankzes = map WorkThanks, workBadges - map WorkBadge
	*  Returns         : void
	******************************************************************************/
    protected void insertWorkcomPackage(Map<Integer, FeedItem> feedItems,
            Map<Integer, WorkThanks> workThankzes,
            Map<Integer, WorkBadge> workBadges){
        insert workThankzes.values();

        // Completed FeedItem
        for (Integer key : feedItems.keySet()) {
            FeedItem feed = feedItems.get(key);
            WorkThanks thanks = workThankzes.get(key);
            feed.RelatedRecordId = thanks.Id;
        }
        insert feedItems.values();

        // Completed WorkBadge
        for (Integer key : workBadges.keySet()) {
            WorkBadge workBadgeItem = workBadges.get(key);
            WorkThanks workThanksItem = workThankzes.get(key);
            workBadgeItem.SourceId = workThanksItem.Id;
        }
        insert workBadges.values();
    }

    // Class for compareTo WorkBadge by DateOfAppointment__c field
    public class WorkBadgeWrapper implements Comparable {
        public WorkBadge wBadge{
            get; private set;
        }

        public WorkBadgeWrapper(WorkBadge workBadgeIn) {
            this.wBadge = workBadgeIn;
        }

        public Integer compareTo(Object compareTo) {
            WorkBadgeWrapper compareToWorkBadge = (WorkBadgeWrapper)compareTo;

            Integer returnValue = 0;
            if (wBadge.DateOfAppointment__c > compareToWorkBadge.wBadge.DateOfAppointment__c) {
                returnValue = 1;
            } else if (wBadge.DateOfAppointment__c < compareToWorkBadge.wBadge.DateOfAppointment__c) {
                returnValue = -1;
            }
            return returnValue;
        }
    }

    public class FleetCorMonthException extends Exception {}

    public class WorkcomComboBadgeNotExistsException extends Exception {}

    public class WorkcomUserPointsDoesNotInitException extends Exception {}
}