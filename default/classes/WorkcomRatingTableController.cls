/**
 * Created by Andrei.Moiseev on 27.11.2017.
 */
public class WorkcomRatingTableController {
	public String url { get; set; }
	private Integer pageSize { get; set; }
	private Map<Id, String> recordsTypeMap { get; set; }

	public WorkcomRatingTableController() {
		url = System.URL.getSalesforceBaseUrl().toExternalForm();
		pageSize = 10;

		this.recordsTypeMap = new Map<Id, String>();
		for(RecordTypeInfo info: WorkBadgeDefinition.SObjectType.getDescribe().getRecordTypeInfos()) {
			if(info.isAvailable()) {
				this.recordsTypeMap.put(info.getRecordTypeId(), info.getName());
			}
		}
	}

	public ApexPages.StandardSetController con {
		get {
			if(con == null) {
				con = new ApexPages.StandardSetController([
						SELECT Name, UserRole.Name, smallphotourl, Points__c, Earned_Points__c
						FROM User
						WHERE Earned_Points__c != null
						AND Points__c != null
						AND IsActive = true
						AND Id IN (SELECT RecipientId FROM WorkBadge WHERE Definition.RecordTypeId = :this.recordsTypeMap.keySet())
						ORDER By Earned_Points__c DESC
						LIMIT 100
				]);
				con.setPageSize(pageSize);
			}
			return con;
		}
		set;
	}

	public List<User> getUserList() {
		return (List<User>)con.getRecords();
	}

	public Boolean hasNext {
		get {
			return con.getHasNext();
		}
		set;
	}

	public Boolean hasPrevious {
		get {
			return con.getHasPrevious();
		}
		set;
	}

	public void first() {
		con.first();
	}

	public void last() {
		con.last();
	}

	public void previous() {
		con.previous();
	}

	public void next() {
		con.next();
	}
}