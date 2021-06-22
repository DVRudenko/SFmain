global class EmarsysGetEmailDataEntity {
    global class Data {
		global String deleted;
		global Integer exclude_filter;
		global String language;
		global String root_campaign_id;
		global String api_status;
		global Integer cc_list;
		global Integer exclude_contactlist;
		global String source;
		global String fromemail;
		global String api_error;
		global String status;
		global Object external_event_id;
		global String additional_linktracking_parameters;
		global String unsubscribe;
		global String contactlist;
		global String text_only;
		global String name;
		global String filter;
		global String email_category;
		global String subject;
		global String fromname;
		global String html_source;
		global String template;
		global String fromemail_host;
		global String browse;
		global String version_name;
		global String text_source;
		global String id;
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