public class LongFormProduct {
    public String productName { get; set; }
    public String productLabel { get; set; }
    public Map<String, LongFormTariff> tariffs { get; set; }
    public Map<String, LongFormTariffProperty> productProperties { get; set; }
}