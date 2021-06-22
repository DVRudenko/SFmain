public with sharing class EmarsysNewContactEntity {
	public String replyText;
	public Integer replyCode;
	public Data data;
	public class Data {
		public Integer[] ids;
	}    
}