public class E2EExceptionServiceDE {
    /*******************************************************************************
    *  Name            : getExceptionPages(String deviceView)
    *  Summary         : Return required pages for exception message    
    *  CreatedDate     : 16/07/2018
    *  ModifiedDate    : 
    *  Parameters      : deviceView – mobile or desktop
    *  Returns         : Map<String, LongFormPage>
    ******************************************************************************/
    public Map<String, LongFormPage> getExceptionPages(String deviceView) {
        E2E_Form_General_Settings__c settings = E2E_Form_General_Settings__c.getInstance('Germany');

        Map<Id, LongForm_Page__c> lfPagesMap = new Map<Id, LongForm_Page__c>([
            SELECT Name, Type__c, Long_Form__c
            FROM LongForm_Page__c
            WHERE Long_Form__r.Country__c = 'Germany' AND
                (Name = 'SYSTEM ERROR' OR Name = 'VOUCHER') AND
                Device_View__c = :deviceView AND
                Long_Form__r.Test_mode__c = :settings.Test_mode__c
            LIMIT 10000
        ]);

        List<LongForm_Element__c> elementsList = [
            SELECT Name, Long_Form_Page__r.Title__c, Long_Form_Page__r.System_Error__c, Long_Form_Page__r.Name, Type__c,
                   (SELECT Name, Active__c, Type__c, Value__c FROM Long_Form_Element_Items__r)
            FROM LongForm_Element__c
            WHERE Long_Form_Page__c IN :lfPagesMap.keySet()
            LIMIT 10000];

        Map<String, LongFormPage> pagesMap = new Map<String, LongFormPage>();
        for (LongForm_Element__c element : elementsList) {
            if (! pagesMap.containsKey(element.Long_Form_Page__r.Name) ) {
                pagesMap.put(element.Long_Form_Page__r.Name, new LongFormPage());
                pagesMap.get(element.Long_Form_Page__r.Name).elements = new Map<String, Map<String, LongFormElementItem>>();
            }

            if (! pagesMap.get(element.Long_Form_Page__r.Name).elements.containsKey(element.Name) ) {
                pagesMap.get(element.Long_Form_Page__r.Name).elements.put(element.Name, new Map<String, LongFormElementItem>());
            }

            for (LongForm_Element_Item__c elementItem : element.Long_Form_Element_Items__r) {
                LongFormElementItem lfElementItem = new LongFormElementItem();
                lfElementItem.value = elementItem.Value__c;
                pagesMap.get(element.Long_Form_Page__r.Name).elements.get(element.Name).put(elementItem.Name, lfElementItem);
            }
        }
        return pagesMap;
    }
}