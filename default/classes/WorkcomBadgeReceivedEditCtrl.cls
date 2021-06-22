public class WorkcomBadgeReceivedEditCtrl {
	public WorkBadge wBadge{get; private set;}
	public User user{get; private set;}
	public WorkBadgeDefinition workBadgeDefinition{get; private set;}
	public String Message{get; set;}
	private FeedItem feedItem;
	private WorkThanks wThanks;


	public WorkcomBadgeReceivedEditCtrl() {
		Id workBadgeId = ApexPages.currentPage().getParameters().get('id');
		Id userId = ApexPages.currentPage().getParameters().get('userId');

		this.wBadge = ([
				SELECT Id, Message, SourceId, DateOfAppointment__c, RecipientId, DefinitionId, GiverId
				FROM WorkBadge
				WHERE Id =: workBadgeId
		]);

		this.workBadgeDefinition = ([
				SELECT Id, Name
				FROM WorkBadgeDefinition
				WHERE Id =: wBadge.DefinitionId
		]);

		this.user = ([
				SELECT Id, Name
				FROM User
				WHERE Id =: wBadge.RecipientId
		]);

		this.wThanks = ([
				SELECT Id, Message, GiverId, FeedItemId, CreatedDate
				FROM WorkThanks
				WHERE Id =: wBadge.SourceId
		]);

		List<FeedItem> feedItemList = ([
				SELECT Id, Body, Title, ParentId, CreatedById, RelatedRecordId, CreatedDate, CreatedBy.Id
				FROM FeedItem
				WHERE ParentId =: userId
		]);

		this.feedItem = GlobalUtils.findFeedItemByWorkThanks(this.wThanks.Id, feedItemList);
		if(this.feedItem != null) {
			this.Message = this.feedItem.Body;
		}else {
			this.Message = wBadge.Message;
		}
	}

	/*******************************************************************************
	*  Name            : save()
	*  Summary         : save changes in FeedItem body
	*  CreatedDate     : 22/12/2017
	*  Parameters      : -
	*  Returns         : PageReference
	******************************************************************************/
	public PageReference save() {
		Savepoint sp = Database.setSavepoint();
		try{
			String dateFormat = DateTime.newInstance(
					wBadge.DateOfAppointment__c.year(),
					wBadge.DateOfAppointment__c.month(),
					wBadge.DateOfAppointment__c.day()
			).format('MM/dd/yyyy');

			String message =
					'Date=\'' + dateFormat.replace('/', '.') + '\' ' + this.Message;

			if(this.feedItem != null) {
				FeedItem newFeedItem = feedItem.clone();
				newFeedItem.Body = message;
				newFeedItem.RelatedRecordId = this.wThanks.Id;
				newFeedItem.CreatedDate = feedItem.CreatedDate;
				newFeedItem.Type = 'RypplePost';
				insert(newFeedItem);

				delete feedItem;
			}else {
				FeedItem newFeedItem =  new FeedItem(
						Body = message,
						Title = 'Work.com',
						ParentId = wBadge.RecipientId,
						CreatedById = wBadge.GiverId,
						RelatedRecordId = this.wThanks.Id,
						CreatedDate = this.wThanks.CreatedDate,
						Type = 'RypplePost');
				insert(newFeedItem);
			}

		}catch (Exception e) {
			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.FATAL, e.getMessage()));
			Database.rollback(sp);
			return null;
		}
		return new PageReference('javascript:window.close()');
	}

	/*******************************************************************************
	*  Name            : cancel()
	*  Summary         : cancel save changes
	*  CreatedDate     : 22/12/2017
	*  Parameters      : -
	*  Returns         : PageReference
	******************************************************************************/
	public PageReference cancel() {
		return new PageReference('javascript:window.close()');
	}
}