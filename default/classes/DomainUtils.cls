global class DomainUtils {

    /* Enum for getting Emarsys Accounts */
    public enum EmarsysAccounts {
        AccountEuro,
        AccountRus
    }

    private static Map<String, String> emarsysAccountsMap = new Map<String, String>{
            'AccountEuro' => 'PPR_EU',
            'AccountRus' => 'PPR'
    };

    public static String getEmarsysAccount(String s) {
        return emarsysAccountsMap.get(s);
    }

    /* Enum for getting Emarsys reaction types*/
    public enum EmarsysReactionTypesRus {
        DefaultReaction,
        Open,
        Click
    }

    private static Map<String, String> emarsysReactionTypesRusMap = new Map<String, String>{
            'DefaultReaction' => 'Reaction Open or Click',
            'Open' => 'Opened',
            'Click' => 'Clicked'
    };

    public static String getEmarsysReactionType(String s) {
        return emarsysReactionTypesRusMap.get(s);
    }

    /* DOMAIN FUNCTIONS */
    /* Blank String field if the value is null */
    public static String blankStringIfNull(String var) {
        return (var != null) ? var : '';
    }

    /* Blank Integer field if the value is null */
    public static Integer blankIntegerIfNull(Integer var) {
        return (var != null) ? var : 0;
    }

    /* Blank Boolean field if the value is null */
    public static Boolean blankBooleanIfNull(Boolean var) {
        return (var != null) ? var : false;
    }

    /* Blank Decimal field if the value is null */
    public static Decimal blankDecimalIfNull(Decimal var) {
        return (var != null) ? var : 0.0;
    }

    /*******************************************************************************
    *  Name            : getPicklistValuesTranslationsList()
    *  Summary         : return the list of translation of the Field picklist values
    *  CreatedDate     : 06.12.2017
    *  Parameters      : Schema.DescribeFieldResult fieldResult - filed description
    *  Returns         : List<Schema.PicklistEntry>
    ******************************************************************************/
    public static List<Schema.PicklistEntry> getPicklistValuesTranslationsList(Schema.DescribeFieldResult fieldResult){
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        return picklist;
    }

    /*******************************************************************************
    *  Name            : getPicklistValueTranslation()
    *  Summary         : return one translation of the picklist value (if translation wasn't found - return current value)
    *  CreatedDate     : 06.12.2017
    *  Parameters      : Schema.DescribeFieldResult fieldResult - filed description
    *                    String currentValue - current value of the picklist
    *  Returns         : Schema.DescribeFieldResult
    ******************************************************************************/
    public static String getPicklistValueTranslation(Schema.DescribeFieldResult fieldResult, String currentValue){
        String finalLabel = '';
        if(currentValue != null){
            finalLabel = currentValue;
        }
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        if(picklist.size() > 0 && (currentValue != null)){
            for(Schema.PicklistEntry entry : picklist) {
                if(entry.getValue().contains(currentValue)){
                    finalLabel = entry.getLabel();
                    break;
                }
            }
        }
        return finalLabel;
    }

    //********** Work.com  *******//

    /*******************************************************************************
   *  Name            : findFeedItemByWorkThanks()
   *  Summary         : find by WorkThanks Id related FeedItem
   *  CreatedDate     : 25/12/2017
   *  Parameters      : workThanksId - WorkThanks Id, feedItems - FeedItem list
   *  Returns         : String
   ******************************************************************************/
    public static FeedItem findFeedItemByWorkThanks(Id workThanksId, List<FeedItem> feedItems) {
        for(FeedItem item : feedItems) {
            if(item.RelatedRecordId == workThanksId) {
                return item;
            }
        }
        return null;
    }

}