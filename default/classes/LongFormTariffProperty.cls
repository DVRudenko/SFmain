public class LongFormTariffProperty {
    public String propertyName { get; set; }
    public String propertyValue { get; set; }
    public String propertyPopup { get; set; }
    public List<LongForm_Property_Item__c> propertyItems { get; set; }
    public Map<String, LongFormTariff> propertyTariffs { get; set; }
}