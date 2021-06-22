public with sharing class DuplicatesContactsController {
	private ApexPages.StandardController controller {get; set;}
    public Contact currentContact {get; set;}
    public List<Contact> finalDupesContactsList {get; set;}

    public DuplicatesContactsController (ApexPages.StandardController controller) {
        this.currentContact = new Contact();
        this.finalDupesContactsList = new List<Contact>();
    }


    /*******************************************************************************
    *  Name            : init()
    *  Summary         : check for duplicates in the Contact field values: Email OR Phone OR (LastName AND FirstName)  
    *  CreatedDate     : 26/09/2017
    *  Parameters      : -
    *  Returns         : void
    ******************************************************************************/
    public void init() {
    	String contactId = ApexPages.currentPage().getParameters().get('id');

    	List<Contact> currentContactList = [
            SELECT FirstName, LastName, Phone, Email
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1];

        if (! currentContactList.isEmpty()) {
            this.currentContact = currentContactList.get(0);

            Set<String> currentContactEmail = new Set<String>();
            Set<String> currentContactPhone = new Set<String>();
            Map<String, String> contactLastNameToFirstNameMap = new Map<String, String>();
            if (this.currentContact.Email != null) {
                currentContactEmail.add(this.currentContact.Email);
            }
            if (this.currentContact.Phone != null) {
                currentContactPhone.add(this.currentContact.Phone);
            }
            if (this.currentContact.FirstName != null) {
                contactLastNameToFirstNameMap.put(this.currentContact.LastName, this.currentContact.FirstName);
            }

            List<Contact> duplicateContactsListTemp = [
                SELECT FirstName, LastName, Phone, Email
                FROM Contact
                WHERE (Email = :currentContactEmail OR 
                    Phone IN :currentContactPhone OR 
                    LastName IN :contactLastNameToFirstNameMap.keySet()) AND
                    Account.RecordType.Name != 'Flexcard' AND
                    Id != :this.currentContact.Id
                LIMIT 1001];

            List<Contact> duplicateContactsList = new List<Contact>();
            for (Contact contact : duplicateContactsListTemp) {
                if (currentContactEmail.contains(contact.Email) || currentContactPhone.contains(contact.Phone) || 
                    (contactLastNameToFirstNameMap.containsKey(contact.LastName) && contactLastNameToFirstNameMap.get(contact.LastName) == contact.FirstName)) {
                    duplicateContactsList.add(contact);
                }
            }

            Integer counter = 0;
            for (Contact con : duplicateContactsList) { 
                if (counter == 1000) break;   
                this.finalDupesContactsList.add(con); 
                counter++;
            }
            if (duplicateContactsList.size() >= 1000) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Table displays 1000 record max.'));
            }
        }  
    }
}