/**
 * Created by Andrei.Moiseev on 20.11.2017.
 */
public class WorkBadgeReceivedPageController {
	public List<WorkBadge> workBadgeList { get; set; }
	public WorkCurrentUser currentUser { get; private set; }
	public Map<Id, String> messageMap { get; private set; }
	public String roleName { get; private set; }

	public WorkBadgeReceivedPageController() {
		if (ApexPages.currentPage().getParameters().get('sfdc.userId') != null) {
			this.currentUser = new WorkCurrentUser(ApexPages.currentPage().getParameters().get('sfdc.userId'));
		} else {
			this.currentUser = new WorkCurrentUser(UserInfo.getUserId());
		}

		if (this.currentUser.isWorkcomUser) {

			this.workBadgeList = new List<WorkBadge>([
					SELECT Definition.Name, Source.Message, GiverId, Giver.Name, CreatedDate, ImageUrl, DateOfAppointment__c
					FROM WorkBadge
					WHERE RecipientId = :currentUser.userObj.Id
					ORDER BY DateOfAppointment__c DESC
			]);

			List<FeedItem> feedItems = ([
					SELECT Id, Body, RelatedRecordId
					FROM FeedItem
					WHERE ParentId = :currentUser.userObj.Id
			]);

			this.messageMap = new Map<Id, String>();
			for (WorkBadge item : workBadgeList) {
				FeedItem temp = GlobalUtils.findFeedItemByWorkThanks(item.SourceId, feedItems);
				if (temp != null) {
					messageMap.put(item.Id, temp.Body);
				} else {
					messageMap.put(item.Id, item.Source.Message);
				}
			}

			this.roleName = ([
					SELECT Name
					FROM UserRole
					WHERE Id = :UserInfo.getUserRoleId()
			]).Name;

		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Sorry, this user is not Work.com member. Please contact your SF administrator.'));
		}
	}

	/*******************************************************************************
	*  Name            : refresh()
	*  Summary         : run method to update current user
	*  CreatedDate     : 20/11/2017
	*  Parameters      : -
	*  Returns         : void
	******************************************************************************/
	public void refresh() {
		try {
			currentUser.refresh();
		}catch (Exception e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
		}

	}
}