public class GoogleTranslateParser {
    public Data data;
    
	public class Data {
		public List<Translations> translations;
	}

	public class Translations {
		public String translatedText;
		public String detectedSourceLanguage;
	}
}