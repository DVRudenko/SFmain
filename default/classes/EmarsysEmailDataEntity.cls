global class EmarsysEmailDataEntity {
    global class Data {
		global String url;
	}

	global class JSON2Apex {
		global String replyText;
		global Integer replyCode;
		global Data data;
	}

	global static JSON2Apex parse(String jsonStr) {
		return (JSON2Apex) JSON.deserialize(jsonStr, JSON2Apex.class);
	}
}