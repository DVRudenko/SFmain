global with sharing class EmarsysEmailHistoryEntity {
	global class Data {
		global String bounce_status;
		global Datetime launch_date;
		global Integer emailId;
		global String contactId;
		global String launchListId;
		global String delivery_status;
	}

	global class JSON2Apex {
		global String replyText;
		global List<Data> data;
		global Integer replyCode;
	}

	global static JSON2Apex parse(String jsonStr) {
		return (JSON2Apex) JSON.deserialize(jsonStr, JSON2Apex.class);
	}
}