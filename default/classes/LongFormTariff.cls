public class LongFormTariff {
    public String tariffName { get; set; }
    public String tariffLabel { get; set; }
    public Boolean showTariff  { get; set; }
    public Map<String, LongFormTariffProperty> properties { get; set; }
}