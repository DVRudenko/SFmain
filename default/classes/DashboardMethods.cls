/**
 * Created by Nikita.Mikhailov on 14.05.2018.
 */

public with sharing class DashboardMethods {

    /*******************************************************************************
    *  Name            : limitsList
    *  Type            : variable
    *  Summary         : List of number of rows to select and show
    *  CreatedDate     : 15/05/2018
    *  Parameters      :
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public static List<SelectOption> limitsList {
        get {
            if (limitsList == null) {
                limitsList = new List<SelectOption>{
                        new SelectOption('10', '10'),
                        new SelectOption('25', '25'),
                        new SelectOption('50', '50'),
                        new SelectOption('100', '100')
                };
                return limitsList;
            }
            return limitsList;
        }
        private set;
    }

    /*******************************************************************************
    *  Name            : monthsMap
    *  Type            : variable
    *  Summary         : Map of number => months names
    *  CreatedDate     : 15/05/2018
    *  Parameters      :
    *  Returns         : Map<Integer, String>
    ******************************************************************************/
    public static Map<Integer, String> monthsMap {
        get {
            if (monthsMap == null) {
                monthsMap = new Map<Integer, String>{
                        1 => 'January',
                        2 => 'February',
                        3 => 'March',
                        4 => 'April',
                        5 => 'May',
                        6 => 'June',
                        7 => 'July',
                        8 => 'August',
                        9 => 'September',
                        10 => 'October',
                        11 => 'November',
                        12 => 'December'
                };
                return monthsMap;
            }
            return monthsMap;
        }
        private set;
    }

    /*******************************************************************************
    *  Name            : userRoleTree
    *  Type            : variable
    *  Summary         : Tree of UserRoles from PPR_Fleetcor
    *  CreatedDate     : 15/05/2018
    *  Parameters      :
    *  Returns         : UserRoleTree
    ******************************************************************************/
    public static UserRoleTree userRoleTree {
        get {
            if (userRoleTree == null) {
                userRoleTree = new UserRoleTree();
                return userRoleTree;
            }
            return userRoleTree;
        }
        private set;
    }

    /*******************************************************************************
    *  Name            : userRoleTree
    *  Type            : variable
    *  Summary         : Hierarchy of UserRoles from PPR_Fleetcor. Data represents like <UserRoleId, List<ChildUserRole>>
    *  CreatedDate     : 15/05/2018
    *  Parameters      :
    *  Returns         : Map<Id, List<UserRole>>
    ******************************************************************************/
    public static Map<Id, List<UserRole>> hierarchy {
        get {
            if (hierarchy == null) {
                hierarchy = new Map<Id, List<UserRole>>();
                for (UserRole role : [SELECT ParentRoleId, Name FROM UserRole]) {
                    if (!hierarchy.containsKey(role.ParentRoleId)) {
                        hierarchy.put(role.ParentRoleId, new List<UserRole>());
                    }
                    hierarchy.get(role.ParentRoleId).add(role);
                }
            }
            return hierarchy;
        }
        private set;
    }

    /*******************************************************************************
    *  Name            : getUser()
    *  Type            : method
    *  Summary         : Get user from SF
    *  CreatedDate     : 28/05/2018
    *  Parameters      :
    *  Returns         : User
    ******************************************************************************/
    public static User getUser(String id)
    {
        return [SELECT Id, Name FROM User WHERE Id = :id];
    }

    /*******************************************************************************
    *  Name            : getYearsList()
    *  Type            : method
    *  Summary         : Display years from Fleetcor_Calendar_Year__c in selectbox
    *  CreatedDate     : 15/05/2018
    *  Parameters      :
    *  Returns         : List<SelectOption>
    ******************************************************************************/
    public static List<SelectOption> getYearsList() {
        List<SelectOption> options = new List<SelectOption>();
        List<Fleetcor_Calendar_Year__c> fltYearsList = [SELECT Name FROM Fleetcor_Calendar_Year__c ORDER BY Name DESC LIMIT 1000];
        for (Fleetcor_Calendar_Year__c fcy : fltYearsList) {
            options.add(new SelectOption(fcy.Name, fcy.Name));
        }
        return options;
    }

    /*******************************************************************************
    *  Name            : returnCurrentYear()
    *  Type            : method
    *  Summary         : Returns current year based on Fleetcor Calendar (custom objects)
    *  CreatedDate     : 10/05/2018
    *  Parameters      :
    *  Returns         : String – year
    ******************************************************************************/
    public static String returnCurrentYear() {
        String currentYear = String.valueOf(Date.today().year());
        Date lastDayOfYear = [
                SELECT End_Date__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Fleetcor_Calendar_Year__r.Name = :currentYear
                ORDER BY End_Date__c DESC
                LIMIT 1
        ].End_Date__c;
        if (Date.today() > lastDayOfYear) {
            return String.valueOf(Date.today().year() + 1);
        } else {
            return String.valueOf(Date.today().year());
        }
    }

    /*******************************************************************************
    *  Name            : returnUserId()
    *  Type            : method
    *  Summary         : getting user ID from URL params
    *  CreatedDate     : 10/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static String returnUserId() {
        String userId = Apexpages.currentPage().getParameters().get('userId');
        if (userId == null) {
            userId = UserInfo.getUserId();
        }

        return userId;
    }

    /*******************************************************************************
    *  Name            : returnUserRoleId()
    *  Type            : method
    *  Summary         : getting UserRoleId from URL params
    *  CreatedDate     : 10/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static String returnUserRoleId() {
        String userRoleId = ApexPages.currentPage().getParameters().get('userroleid');
        if (userRoleId == null) {
            userRoleId = UserInfo.getUserRoleId();
        }

        return userRoleId;
    }

    /*******************************************************************************
    *  Name            : getUserRole()
    *  Type            : method
    *  Summary         : getting UserRole from URL params
    *  CreatedDate     : 10/05/2018
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public static UserRole getUserRole(String Id) {
        try {
            return [SELECT Id FROM UserRole WHERE Id = :id];
        } catch (Exception e) {
            return null;
        }
    }

    /*******************************************************************************
    *  Name            : getPeriodsList()
    *  Type            : method
    *  Summary         : generating FLT periods (months and weeks) list
    *  CreatedDate     : 08/05/2018
    *  Parameters      : -
    *  Returns         : SelectOption (FLT periods)
    ******************************************************************************/
    public static List<SelectOption> getPeriodsList(String selectedYear) {
        String thisMonth = '';
        Integer monthIndex = 12;

        List<Fleetcor_Calendar_Month__c> currentWeekTemp = [
                SELECT Name, Month_Number__c
                FROM Fleetcor_Calendar_Month__c
                WHERE Fleetcor_Calendar_Year__r.Name = :selectedYear AND
                Start_Date__c <= TODAY AND
                End_Date__c >= TODAY
                LIMIT 1
        ];

        List<SelectOption> options = new List<SelectOption>();
        Set<String> monthsSet = new Set<String>();

        if (!currentWeekTemp.isEmpty()) {
            for (Integer i = 1; i <= currentWeekTemp.get(0).Month_Number__c; i++) {
                monthsSet.add(DashboardMethods.monthsMap.get(i));// monthsMap.get(i));
            }
            monthIndex = Integer.valueOf(currentWeekTemp.get(0).Month_Number__c);
        } else {
            for (Integer i = 1; i <= 12; i++) {
                monthsSet.add(DashboardMethods.monthsMap.get(i));
            }
        }

        List<Fleetcor_Calendar_Week__c> weeksList = [
                SELECT End_Date__c, Start_Date__c, Fleetcor_Calendar_Month__r.Name,
                        Fleetcor_Calendar_Month__c
                FROM Fleetcor_Calendar_Week__c
                WHERE Fleetcor_Calendar_Month__r.Name IN :monthsSet AND
                Fleetcor_Calendar_Month__r.Fleetcor_Calendar_Year__r.Name = :selectedYear
                ORDER BY Start_Date__c DESC
        ];

        for (Fleetcor_Calendar_Week__c week : weeksList) {

            if (thisMonth != week.Fleetcor_Calendar_Month__r.Name) {
                thisMonth = week.Fleetcor_Calendar_Month__r.Name;
                options.add(new SelectOption(week.Fleetcor_Calendar_Month__c, DashboardMethods.monthsMap.get(monthIndex)));
                if (monthIndex != 1) {
                    monthIndex--;
                }
            }

            options.add(
                    new SelectOption(
                            week.Id,
                            '---' + week.Fleetcor_Calendar_Month__r.Name + ' (' + week.Start_Date__c.day() + '.' + week.Start_Date__c.month() + ' - ' +
                                    week.End_Date__c.day() + '.' + week.End_Date__c.month() + ')'));
        }
        return options;
    }

    /*******************************************************************************
    *  Name            : UserRoleTree
    *  Type            : class
    *  Summary         : UserRole tree class
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    ******************************************************************************/
    public class UserRoleTree {

        public UserRoleTreeNode root { get; private set; }
        public Integer size { get; private set; }

        public UserRoleTree() {
            if (root == null) {
                size = 1;
                root = new UserRoleTreeNode(hierarchy.get(null).get(hierarchy.get(null).indexOf(new UserRole(Id = '00E0O0000023vGQUAY', Name = 'PPR_Fleetcor'))), new List<UserRoleTreeNode>());
                fillTree(root);
            }
        }

        /*******************************************************************************
        *  Name            : fillTree(UserRoleTreeNode node)
        *  Type            : method
        *  Summary         : fill the UserRole tree from PPR_Fleetcor UserRole
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : void
        ******************************************************************************/
        private void fillTree(UserRoleTreeNode node) {

            if (hierarchy.get(node.value.Id) == null) {
                return;
            }

            for (UserRole userRoleEntry : hierarchy.get(node.value.Id)) {
                UserRoleTreeNode leaf = new UserRoleTreeNode(userRoleEntry, new List<UserRoleTreeNode>());
                fillTree(leaf);
                node.leafs.add(leaf);
                size++;
            }
        }

        /*******************************************************************************
        *  Name            : findNode(UserRole userRole, UserRoleTreeNode node)
        *  Type            : method
        *  Summary         : find UserRole tree node with specific UserRole
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : UserRoleTreeNode
        ******************************************************************************/
        public UserRoleTreeNode findNode(UserRole userRole, UserRoleTreeNode node) {
            if (node.value.Id == userRole.Id) {
                return node;
            } else if (node.leafs == null) {
                return null;
            } else {
                for (UserRoleTreeNode leaf : node.leafs) {
                    UserRoleTreeNode buf = findNode(userRole, leaf);
                    if (buf != null) {
                        return buf;
                    }
                }
            }

            return null;
        }

        /*******************************************************************************
        *  Name            : toUserRoleList(UserRole userRole)
        *  Type            : method
        *  Summary         : convert UserRole tree to hierarchy sorted list of UserRoles from specific UserRole
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : List<UserRole>
        ******************************************************************************/
        public List<UserRole> toUserRoleList(UserRole userRole) {
            UserRoleTreeNode fromNode = findNode(userRole, root);
            List<UserRole> nodeList = new List<UserRole>();
            addUserRoles(fromNode, nodeList);
            return nodeList;
        }

        /*******************************************************************************
        *  Name            : addUserRoles(UserRoleTreeNode node, List<UserRole> nodeList)
        *  Type            : method
        *  Summary         : add recursively UserRole from UserRole tree to output list
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : void
        ******************************************************************************/
        private void addUserRoles(UserRoleTreeNode node, List<UserRole> nodeList) {
            if (node.leafs == null) {
                nodeList.add(node.value);
                return;
            }

            nodeList.add(node.value);
            for (UserRoleTreeNode userRoleTreeNode : node.leafs) {
                addUserRoles(userRoleTreeNode, nodeList);
            }
        }

        /*******************************************************************************
        *  Name            : toIdList(UserRole userRole)
        *  Type            : method
        *  Summary         : convert UserRole tree to hierarchy sorted list of UserRoles Ids from specific UserRole
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : List<Id>
        ******************************************************************************/
        public List<Id> toIdList(UserRole userRole) {
            UserRoleTreeNode fromNode = findNode(userRole, root);
            List<Id> nodeList = new List<Id>();
            addIds(fromNode, nodeList);
            return nodeList;
        }

        /*******************************************************************************
        *  Name            : addIds(UserRoleTreeNode node, List<UserRole> nodeList)
        *  Type            : method
        *  Summary         : add recursively UserRole Id from UserRole tree to output list
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : void
        ******************************************************************************/
        private void addIds(UserRoleTreeNode node, List<Id> nodeList) {
            if (node.leafs == null) {
                nodeList.add(node.value.Id);
                return;
            }

            nodeList.add(node.value.Id);
            for (UserRoleTreeNode userRoleTreeNode : node.leafs) {
                addIds(userRoleTreeNode, nodeList);
            }
        }

        /*******************************************************************************
        *  Name            : toListWithLevels(UserRole userRole)
        *  Type            : method
        *  Summary         : convert UserRole tree to hierarchy sorted list with dash('- ') levels of UserRoles Ids from specific UserRole
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : List<String>
        ******************************************************************************/
        private String dash;
        public List<String> toListWithLevels(UserRole userRole) {
            UserRoleTreeNode fromNode = findNode(userRole, root);
            dash = '';
            List<String> nodeList = new List<String>();
            addIdsWithLevels(fromNode, nodeList);
            return nodeList;
        }

        /*******************************************************************************
        *  Name            : addIdsWithLevels(UserRoleTreeNode node, List<UserRole> nodeList)
        *  Type            : method
        *  Summary         : add recursively dash('- ') + UserRole Id from UserRole tree to output list
        *  CreatedDate     : 15/05/2018
        *  Parameters      : -
        *  Returns         : void
        ******************************************************************************/
        private void addIdsWithLevels(UserRoleTreeNode node, List<String> nodeList) {
            if (node.leafs == null) {
                nodeList.add(dash + ' ' + node.value.Id);
                return;
            }

            nodeList.add(dash + ' ' + node.value.Id);
            dash += '- ';
            for (UserRoleTreeNode userRoleTreeNode : node.leafs) {
                addIdsWithLevels(userRoleTreeNode, nodeList);
                dash = dash.substring(2);
            }
        }
    }

    /*******************************************************************************
    *  Name            : UserRoleTreeNode
    *  Type            : class
    *  Summary         : UserRole tree node class
    *  CreatedDate     : 15/05/2018
    *  Parameters      : -
    ******************************************************************************/
    public class UserRoleTreeNode {
        public UserRole value { get; set; }
        public List<UserRoleTreeNode> leafs { get; set; }

        public UserRoleTreeNode(UserRole value, List<UserRoleTreeNode> leafs) {
            this.value = value;
            this.leafs = leafs;
        }
    }

}