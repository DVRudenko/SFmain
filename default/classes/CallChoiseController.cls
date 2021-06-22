public class CallChoiseController {
	public String namefield {get; set;}
	public String idfield {get; set;}
	public String opportunityId {get; set;}
	public List<Task> tasksList {get; set;}

	public void init() {
		this.namefield = ApexPages.currentPage().getParameters().get('callfield');
		this.idfield = ApexPages.currentPage().getParameters().get('idfield');
		this.opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
		this.tasksList = [
		        SELECT Subject, ActivityDate, Status, Priority, LastModifiedDate
		        FROM Task
		        WHERE WhatId = :opportunityId AND CallObject != null];
	}
}