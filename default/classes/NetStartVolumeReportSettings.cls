public class NetStartVolumeReportSettings {
    public Integer netStartsWeeksCount { get; private set; }
    public Integer volumeWeeksCount { get; private set; }
    public Integer weeksCount { get; private set; }
    public List<String> reportFields { get; private set; }
    public Map<String, String> labelAndSelectorNameBundle { get; private set; }
    public List<String> orderedSelectorLabels { get; private set; }
    public Map<String, String> selectorNameToDataGenerator { get; private set; }
    public Map<String, List<Object>> defaultFilters { get; private set; }
    public Map<Id, UserRole> userRoleMap { get; private set; }
    public Map<Id, User> userMap { get; private set; }
    public Map<String, String> translateLabels = new Map<String, String> {
            'Country' => Label.RU_0039_Country,
            'Transit ID' => Label.RU_0040_Transit_ID,
            'Name' => Label.RU_0041_Opportunity_Name,
            'Status Contract' => Label.RU_0042_Status_Contract,
            'Category Contract' => Label.RU_0045_Category_Contract,
            'First Contact' => Label.RU_0046_First_Contact,
            'Owner' => Label.RU_0057_Owner,
            'Role' => Label.RU_0056_Role,
            'Starts Manager' => Label.RU_0047_Starts_Manager,
            'Close Date' => Label.RU_0048_Close_Date,
            'First Pump Date' => Label.RU_0049_First_Pump_Date,
            'All Cards' => Label.RU_0050_All_Cards,
            'Number Cards' => Label.RU_0051_Number_Cards,
            'Liters Weekly' => Label.RU_0052_Liters_Weekly,
            'Expected Volume' => Label.RU_0053_Expected_Volume,
            'Reality and Expected' => Label.RU_0054_Reality_And_Expected,
            'Product PPR' => Label.RU_0055_Product_PPR,
            'Volume 1' => Label.RU_0043_Volume_1 + ' 1',
            'Volume 2' => Label.RU_0043_Volume_1 + ' 2',
            'Volume 3' => Label.RU_0043_Volume_1 + ' 3',
            'Volume 4' => Label.RU_0043_Volume_1 + ' 4',
            'Volume 5' => Label.RU_0043_Volume_1 + ' 5',
            'Volume 6' => Label.RU_0043_Volume_1 + ' 6',
            'Volume 7' => Label.RU_0043_Volume_1 + ' 7',
            'Volume 8' => Label.RU_0043_Volume_1 + ' 8',
            'Volume 9' => Label.RU_0043_Volume_1 + ' 9',
            'Volume 10' => Label.RU_0043_Volume_1 + ' 10',
            'Volume 11' => Label.RU_0043_Volume_1 + ' 11',
            'Volume 12' => Label.RU_0043_Volume_1 + ' 12',
            'Volume 13' => Label.RU_0043_Volume_1 + ' 13',
            'Volume 14' => Label.RU_0043_Volume_1 + ' 14',
            'Volume 15' => Label.RU_0043_Volume_1 + ' 15',
            'Volume 16' => Label.RU_0043_Volume_1 + ' 16',
            'NetStarts 1' => Label.RU_0044_NetStarts_1 + ' 1',
            'NetStarts 2' => Label.RU_0044_NetStarts_1 + ' 2',
            'NetStarts 3' => Label.RU_0044_NetStarts_1 + ' 3',
            'NetStarts 4' => Label.RU_0044_NetStarts_1 + ' 4',
            'NetStarts 5' => Label.RU_0044_NetStarts_1 + ' 5',
            'NetStarts 6' => Label.RU_0044_NetStarts_1 + ' 6',
            'NetStarts 7' => Label.RU_0044_NetStarts_1 + ' 7',
            'NetStarts 8' => Label.RU_0044_NetStarts_1 + ' 8',
            'NetStarts 9' => Label.RU_0044_NetStarts_1 + ' 9',
            'NetStarts 10' => Label.RU_0044_NetStarts_1 + ' 10',
            'Sum NetStarts' => Label.RU_0044_Sum_NetStarts,
            'First Payed Transit' => Label.RU_0059_First_Payed_Transit,
            'Transit Non Volume First Date' => Label.RU_0064_PPR_Transit_Non_Volume_First_Date,
            'INN' => Label.RU_0060_INN
    };

    public NetStartVolumeReportSettings(NetStartVolumeReportSettings.BusinessType businessType,
                                        NetStartVolumeReportSettings.ReportType reportType) {

        Id currentUserId = UserInfo.getUserId();
        Id currentRoleId = UserInfo.getUserRoleId();
        Set<Id> rolesSetDefault = GlobalUtils.getSubordinateRoles(currentRoleId);

        if (rolesSetDefault != null && rolesSetDefault.size() != 0) {
            this.userMap = new Map<Id, User>([
                    SELECT Id, Name
                    FROM User
                    WHERE UserRoleId IN :rolesSetDefault
                    OR Id = :currentUserId
                    OR Name = 'E2E RU Site Guest User' //E2E RU Site Guest User
            ]);

            this.userRoleMap = new Map<Id, UserRole>([
                    SELECT Id, Name
                    FROM UserRole
                    WHERE Id IN :rolesSetDefault
                    OR Id = :currentRoleId
            ]);

            userRoleMap.put(null, null); //As long as E2E RU Site Guest User has no Role, so null is Role Id of this user

        } else {
            this.userMap = new Map<Id, User>([
                    SELECT Id, Name
                    FROM User
                    WHERE Id = :currentUserId
                    OR Name = 'E2E RU Site Guest User' //E2E RU Site Guest User
            ]);

            this.userRoleMap = new Map<Id, UserRole>([
                    SELECT Id, Name
                    FROM UserRole
                    WHERE Id = :currentRoleId
            ]);

            userRoleMap.put(null, null); //As long as E2E RU Site Guest User has no Role, so null is Role Id of this user
        }

        if (businessType == NetStartVolumeReportSettings.BusinessType.EastEurope &&
                reportType == NetStartVolumeReportSettings.ReportType.Onboarding) {
            this.reportFields = new List<String>{
                    'Role',
                    'Owner',
                    'Name',
                    'Category Contract',
                    'Starts Manager',
                    'Close Date',
                    'All Cards',
                    'Number Cards',
                    'Liters Weekly',
                    'Expected Volume',
                    'Reality and Expected',
                    'First Payed Transit',
                    'Transit Non Volume First Date',
                    'First Pump Date',
                    'Volume 1',
                    'Volume 2',
                    'Volume 3',
                    'Volume 4',
                    'Volume 5',
                    'Volume 6',
                    'Volume 7',
                    'Volume 8',
                    'Volume 9',
                    'Volume 10',
                    'Volume 11',
                    'Volume 12',
                    'Volume 13',
                    'Volume 14',
                    'Volume 15',
                    'Volume 16',
                    'NetStarts 1',
                    'NetStarts 2',
                    'NetStarts 3',
                    'NetStarts 4',
                    'NetStarts 5',
                    'NetStarts 6',
                    'NetStarts 7',
                    'NetStarts 8',
                    'NetStarts 9',
                    'NetStarts 10',
                    'Sum NetStarts',
                    'INN',
                    'Product PPR',
                    'Transit ID'
            };

            this.orderedSelectorLabels = new List<String> {
                    'ИНН',
                    'Transit ID',
                    'Роль владельца',
                    'Владелец возможности',
                    'Первый контакт',
                    'Менеджер сервисного отдела',
                    'Дата постановки на старт',
                    'Дата первой транзакции',
                    'Наличие транзакций',
                    'Источник интереса'
            };

            this.labelAndSelectorNameBundle = new Map<String, String>{
                    'Роль владельца' => 'roleEE',
                    'Владелец возможности' => 'oppOwner',
                    'Первый контакт' => 'secChannelEE',
                    'Менеджер сервисного отдела' => 'startsManagerEE',
                    'Дата постановки на старт' => 'closedDate',
                    'Дата первой транзакции' => 'firstPumpDate',
                    'Наличие транзакций' => 'firstPumpDateEE',
                    'Источник интереса' => 'sourceOfLead',
                    'ИНН' => 'InnSTR',
                    'Transit ID' => 'TransitIdSTR'
            };

            this.selectorNameToDataGenerator = new Map<String, String>{
                    'secChannelEE' => 'NetStartsVolumeFilterGenerator.SecChannelOptionsEE',
                    'firstPumpDateEE' => 'NetStartsVolumeFilterGenerator.FirstPumpDateOptions',
                    'roleEE' => 'NetStartsVolumeFilterGenerator.RolesOptions',
                    'oppOwner' => 'NetStartsVolumeFilterGenerator.OwnerOptions',
                    'startsManagerEE' => 'NetStartsVolumeFilterGenerator.StartManagerOptionsEE',
                    'closedDate' => 'NetStartsVolumeFilterGenerator.DateFromTo',
                    'sourceOfLead' => 'NetStartsVolumeFilterGenerator.SourceOfLeadOptions',
                    'firstPumpDate' => 'NetStartsVolumeFilterGenerator.DateFromToPump',
                    'InnSTR' => 'String',
                    'TransitIdSTR' => 'String'
            };

            this.defaultFilters = new Map<String, List<Object>> {
                    'oppOwner' => new List<Object>{ userMap.keySet() },
                    'roleEE' => new List<Object>{ userRoleMap.keySet() },
                    'stageName' => new List<Object>{ new Set<String>{'Moved to start'}},
                    'InnSTR' => new List<Object>{},
                    'TransitIdSTR' => new List<Object>{}
            };

            this.netStartsWeeksCount = 16;
            this.volumeWeeksCount = 16;
            this.weeksCount = 16;
        } else {
            throw new NotSupportReportException('Not support report type!');
        }
    }

    public class ReferenceBundle {
        public String name { get; set; }
        public Id refer { get; set; }

        public ReferenceBundle(Id refer, String name) {
            this.refer = refer;
            this.name = name;
        }
    }

    public enum BusinessType {Europe, EastEurope}
    public enum ReportType {Onboarding}
    public enum OnboardingReportHtmlGeneratorType { EXCEL, CSV, HTML, SELECTOR }

    public class NotSupportReportException extends Exception {}

}