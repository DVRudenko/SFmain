public class GeocoderGoogle {

    public results[] results;
    public String status;	//OK

    public class results {
        public address_components[] address_components;
        public String formatted_address;	//Ulitsa Gagarina, 1г, Martyush, Sverdlovskaya oblast', Russia, 623462
        public geometry geometry;
        public String place_id;	//ChIJvSUya4rZxkMRvL_g1dUp4wo
        public plus_code plus_code;
        public String[] types;
    }

    public class address_components {
        public String long_name;	//1г
        public String short_name;	//1г
        public String[] types;
    }

    public class geometry {
        public location location;
        public String location_type;	//ROOFTOP
        public viewport viewport;
    }

    public class location {
        public Double lat;	//56.4000363
        public Double lng;	//61.8874452
    }

    public class viewport {
        public northeast northeast;
        public southwest southwest;
    }

    public class northeast {
        public Double lat;	//56.4013852802915
        public Double lng;	//61.88879418029151
    }

    public class southwest {
        public Double lat;	//56.3986873197085
        public Double lng;	//61.88609621970849
    }

    public class plus_code {
        public String compound_code;	//CV2P+2X Martyush, Sverdlovsk Oblast, Russia
        public String global_code;	//9J83CV2P+2X
    }

}