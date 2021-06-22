public class GoogleSpeedAnalystParser {
    public LighthouseResult lighthouseResult {get;set;}

    public class LighthouseResult {
		public Audits audits {get;set;}
        public Categories categories {get;set;}
        public ConfigSettings configSettings {get;set;}
    }

    public class Audits {
		public Metrics metrics {get;set;}
    }

    public class Metrics {
		public Details_O details {get;set;}
	}

    public class Details_O {
		public List<Items_T> items {get;set;}
    }

    public class Items_T {
		public Decimal firstContentfulPaint {get;set;}
		public Decimal speedIndex {get;set;}
    }

    public class Categories {
		public Performance performance {get;set;}
	}

    public class Performance {
		public String id {get;set;}
		public String title {get;set;}
		public Decimal score {get;set;}
    }

    public class ConfigSettings {
		public String emulatedFormFactor {get;set;}
	}
}