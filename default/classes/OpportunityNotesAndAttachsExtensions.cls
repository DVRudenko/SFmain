public with sharing class OpportunityNotesAndAttachsExtensions {
	public String opptyId15digit {get; set;}
	public Map<Id, NotesAndAttachments> allNotesAndAttachmentsMap {get; set;}
	public Map<String, User> fileCreatorsMap {get; set;}
	public Boolean noteAndAttachsListNotEmpty {get; set;}
	public String objectToDeleteId {get; set;}
	private Map<Id, Attachment> allAttachmentsMap;
	private Map<Id, Note> allNotesMap;
	public String cfProfilesStr {get; set;}
	public User currentUser {get; set;}
    

    /*******************************************************************************
    *  Name            : OpportunityNotesAndAttachsExtensions (ApexPages.StandardController stdController)
    *  Summary         : standard controller constructor (load attachments and notes data)   
    *  CreatedDate     : 20/10/2017
    *  Parameters      : ApexPages.StandardController stdController
    *  Returns         : -
    ******************************************************************************/
    public OpportunityNotesAndAttachsExtensions (ApexPages.StandardController stdController) {
    	Opportunity currentOppty = (Opportunity)stdController.getRecord();
    	this.opptyId15digit = String.valueOf(currentOppty.Id).substring(0, 15);
    	String userId = UserInfo.getUserId();

    	this.currentUser = [
            SELECT UserRole.Name, Profile.Name, Name, UserRoleId
            FROM User
            WHERE Id = :userId];

    	this.allAttachmentsMap = new Map<Id, Attachment>([
    		SELECT Id, Name, LastModifiedDate, CreatedById 
    		FROM Attachment
    		WHERE ParentId = :currentOppty.Id
    		LIMIT 50000]);

		this.allNotesMap = new Map<Id, Note>([
			SELECT Id, Title, LastModifiedDate, CreatedById
			FROM Note
			WHERE ParentId = :currentOppty.Id
			LIMIT 50000]);

		Set<String> creatorsNoteAndAttachsSet = new Set<String>();
		for (Attachment attachment : this.allAttachmentsMap.values()) {
			creatorsNoteAndAttachsSet.add(attachment.CreatedById);
		}
		for (Note note : this.allNotesMap.values()) {
			creatorsNoteAndAttachsSet.add(note.CreatedById);
		}
		this.fileCreatorsMap = new Map<String, User>([
			SELECT Name
			FROM User
			WHERE Id IN :creatorsNoteAndAttachsSet
		]);
	
 		this.allNotesAndAttachmentsMap = new Map<Id, NotesAndAttachments>();		
		if (! this.allAttachmentsMap.isEmpty() ) {
			for (Attachment attachment : this.allAttachmentsMap.values()) {
				NotesAndAttachments notesAndAttachs = new NotesAndAttachments();
				notesAndAttachs.objectId = attachment.Id;
				notesAndAttachs.type = 'Attachment';
				notesAndAttachs.name = attachment.Name;
				notesAndAttachs.lastModifiedDate = attachment.LastModifiedDate.format('dd/MM/yyyy HH:mm');
				notesAndAttachs.createdById = attachment.CreatedById;
				this.allNotesAndAttachmentsMap.put(notesAndAttachs.objectId, notesAndAttachs);
			}	
		}
		if (! this.allNotesMap.isEmpty() ) {
			for (Note note : this.allNotesMap.values()) {
				NotesAndAttachments notesAndAttachs = new NotesAndAttachments();
				notesAndAttachs.objectId = note.Id;
				notesAndAttachs.type = 'Note';
				notesAndAttachs.name = note.Title;
				notesAndAttachs.lastModifiedDate = note.LastModifiedDate.format('dd/MM/yyyy HH:mm');
				notesAndAttachs.createdById = note.CreatedById;
				this.allNotesAndAttachmentsMap.put(notesAndAttachs.objectId, notesAndAttachs);
			}
		}
		
		//remove Credit Factory report for certain user
		List<Access_to_CF_Reports__c> customSettingsList = Access_to_CF_Reports__c.getAll().values();
		Set<String> profilesSet = new Set<String>();
		this.cfProfilesStr = '';
		for (Access_to_CF_Reports__c cs : customSettingsList) {
			profilesSet.add(cs.Name);
			this.cfProfilesStr += cs.Name + ',';
		}
		for (Id objId : this.allNotesAndAttachmentsMap.keySet()) { 
			if (! profilesSet.contains(currentUser.Profile.Name) && 
				(this.allNotesAndAttachmentsMap.get(objId).name == 'CrefoReport.pdf' || this.allNotesAndAttachmentsMap.get(objId).name == 'CreditsafeReport.pdf' ||
					this.allNotesAndAttachmentsMap.get(objId).name == 'CrifReport.pdf' || this.allNotesAndAttachmentsMap.get(objId).name == 'CofaceReport.pdf')) {
				this.allNotesAndAttachmentsMap.remove(objId);
			}
		}
		if (this.allNotesAndAttachmentsMap.size() != 0) {
			this.noteAndAttachsListNotEmpty = true;
		}
    }

    /*******************************************************************************
    *  Name            : doDelete()
    *  Summary         : action when you click the delete button (deleting note or attachment)    
    *  CreatedDate     : 20/10/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void doDelete(){
		if(this.objectToDeleteId == null){
			return;
		}
		//find note or attachment record within the collection
		NotesAndAttachments tobeDeleted = null;
		for (NotesAndAttachments obj : this.allNotesAndAttachmentsMap.values()) {
			if (obj.objectId == this.objectToDeleteId){
				tobeDeleted = obj;
				break;
			}					
		}
		//if record found delete it
		if (tobeDeleted != null && tobeDeleted.type == 'Attachment') {
			Delete this.allAttachmentsMap.get(tobeDeleted.objectId);
		} else if (tobeDeleted != null && tobeDeleted.type == 'Note') {
			Delete this.allNotesMap.get(tobeDeleted.objectId);
		}
	}

	public class NotesAndAttachments {
        public String objectId {get; set;}
        public String type {get; set;}
        public String name {get; set;}
        public String lastModifiedDate {get; set;}
        public String createdById {get; set;}
    }
}