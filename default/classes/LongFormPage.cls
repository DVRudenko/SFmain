public class LongFormPage {
	public String systemError;
	public String pageTitle {get; set;}
	public Map<String, Map<String, LongFormElementItem>> elements {get; set;}
	public Map<String, LongFormField> fields {get; set;}


    public LongFormPage() {     
    }
}