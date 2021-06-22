import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

/** Apex methods from EventRecordPageController */
import search from '@salesforce/apex/EventRecordPageController.search';
import getEventData from '@salesforce/apex/EventRecordPageController.getEventData';
import getSObjectData from '@salesforce/apex/EventRecordPageController.getSObjectData';
import getPickListValues from '@salesforce/apex/EventRecordPageController.getPickListValues';
import saveEditedEvent from '@salesforce/apex/EventRecordPageController.saveEditedEvent';

export default class EditEventRecordPage extends NavigationMixin(LightningElement) {
    //base parameters
    @api recordId;
    @track eventData = {};
    @track descriptionText = ''


    //custom lookup parameters
    ownerIderrors = [];
    whoIdErrors = [];
    whatIdErrors = [];
    newRecordOptions = [];
    newNameOptions = [];

    // lookup records(relationship)
    relatedToRecord = [];
    nameRecord = [];
    ownerRecord = [];

    //piclist options
    relatedToOptions = [];          //Related To(WhatId) object picklist
    nameObjectOptions = [];         //Name (WhoId) object picklist
    subjectOptions = [];            //Subject field picklist
    typeOptions = [];               //Type field picklist
    showAsOptions = [];             //ShowAs field picklist

    //picklist default options
    relatedToObject = 'Account';    //Related To(WhatId) default value
    nameObject = 'Contact';         //Name(WhoId) default value




    /******************************************************
     * init
     *****************************************************/
    connectedCallback() {
        let params = {
            recordId: this.recordId
        };
        getEventData(params).then( result => {
            this.eventData = Object.assign({}, result);
            this.descriptionText = this.eventData.Description;
            this.setRelatedToField(result);
            this.setNameField(result);
            this.setOwnerRecord(result);
        }).catch(error => {
            this.notifyUser('Init Error', 'An error occured while getting the Event record data.', 'error');
            console.error('Init error', JSON.stringify(error));
            this.errors = [error];
        });
        this.getPickLists();
    }

    /*********************************************
     * lookup search handlers
     *******************************************/
    handleRelatedToSearch(event) {
        this.handleLookupSearch(event, this.relatedToObject);
    }


    handleNameSearch(event) {
        this.handleLookupSearch(event, this.nameObject);
    }


    handleUserSearch(event) {
        this.handleLookupSearch(event, 'User');
    }

    handleLookupSearch(event, sObjectName) {
        const target = event.target;
        let parameters = event.detail;
        parameters.sObjectName = sObjectName;
        // Call Apex endpoint to search for records and pass results to the lookup
        search(event.detail)
            .then((results) => {
                target.setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }


    /******************************************************
     * checks lookups for error
     *****************************************************/
    checkForErrors(event, errors) {
        errors = [];
        const target = event.target;
        const selection = target.getSelection();
        // Custom validation rule
        if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
            errors.push({ message: `You may only select up to ${this.maxSelectionSize} items.` });
        }
        // Enforcing required field
        if (selection.length === 0) {
            errors.push({ message: 'Please make a selection.' });
        }
    }


    /******************************************************
     * shows toast with message to notify user about error or success
     *****************************************************/
    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast (only works in LEX)
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }


    /******************************************************
     * sets default RelatedTo value
     *****************************************************/
    setRelatedToField(eventData) {
        getSObjectData({
            recordId : eventData.WhatId
        }).then((result)=>{
            if(result) {
                this.relatedToRecord = [
                    {
                        id: result.Id,
                        sObjectType: result.SObjectName,
                        icon: 'standard:account',
                        title: result.Name,
                        subtitle: ''
                    }
                ];
                this.relatedToObject = result.SObjectName;
                this.newRecordOptions = [
                    { value: result.SObjectName, label: 'New ' + result.SObjectName }
                ];
            }
        }).catch((error)=>{
            this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
            // eslint-disable-next-line no-console
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }


    /******************************************************
     * sets default Name value
     *****************************************************/
    setNameField(eventData) {
        getSObjectData({
            recordId : eventData.WhoId
        }).then((result)=>{
            if(result) {
                this.nameRecord = [
                    {
                        id: result.Id,
                        sObjectType: result.SObjectName,
                        icon: 'standard:contact',
                        title: result.Name,
                        subtitle: ''
                    }
                ];
                this.nameObject = result.SObjectName;
                this.newNameOptions = [
                    { value: result.SObjectName, label: 'New ' + result.SObjectName }
                ];
            }
        }).catch((error)=>{
            this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
            // eslint-disable-next-line no-console
            console.error('Lookup error', JSON.stringify(error));
            this.errors = [error];
        });
    }


    /******************************************************
     * sets default OwnerId value
     *****************************************************/
    setOwnerRecord(eventData) {
        this.ownerRecord = [
            {
                id: eventData.OwnerId,
                sObjectType: 'User',
                icon: 'standard:user',
                title: eventData.Owner.Name,
                subtitle: ''
            }
        ];  
    }


    /******************************************************
     * saves event record changes and navigates to creation pages
     *****************************************************/
    saveAndCreateNew(event) {
        let whoId = null;
        let whatId = null;
        if(this.nameRecord && this.nameRecord[0]) {
            whoId = this.nameRecord[0].id;
        }
        if(this.relatedToRecord && this.relatedToRecord[0]) {
            whatId = this.relatedToRecord[0].id;
        }
        this.eventData.WhoId = whoId;
        this.eventData.WhatId = whatId;
        this.eventData.OwnerId = this.ownerRecord[0].id;
        this.eventData.ReminderDateTime = this.eventData.StartDateTime;
        saveEditedEvent({ editedEvent : this.eventData }).then(result => {
            this.navigateToNewEventWithDefaults();
            this.notifyUser('', 'Success', 'success');
        }).catch(error =>  {
            console.error('Lookup error', error);
            if(error && error.body && error.body.fieldErrors) {
                for(let fieldError in error.body.fieldErrors) {
                    console.log('error.body.fieldErrors===', fieldError);
                    this.notifyUser('Save Error', error.body.fieldErrors[fieldError][0].message, 'error');
                }
            }
        });
    }


    /******************************************************
     * navigate to new record page with dafault values
     *****************************************************/
    navigateToNewEventWithDefaults() {
        const defaultValues = encodeDefaultFieldValues({
            Subject: this.eventData.Subject,
            Type: this.eventData.Type,
            RecordTypeId: this.eventData.RecordTypeId,
            StartDateTime: this.eventData.StartDateTime,
            EndDateTime: this.eventData.EndDateTime,
            Description: this.eventData.Description,
            WhoId: this.eventData.WhoId,
            WhatId: this.eventData.WhatId,
            OwnerId: this.eventData.OwnerId,
            IsPrivate: this.eventData.IsPrivate,
            IsAllDayEvent: this.eventData.IsAllDayEvent,
            IsReminderSet: this.eventData.IsReminderSet,
            Location: this.eventData.Location,
            ShowAs: this.eventData.ShowAs
        });


        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Event',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }


    /******************************************************
     * get picklists values from server side
     *****************************************************/
    getPickLists() {
        getPickListValues().then( result =>{
            let options = [];
            let nameOptions = [];
            let typeOptions = [];
            let subjectOptions = [];
            let showAsOptions = [];
            let isSubjectInPicklist = false;
            console.log('this.eventData.Subject === ',this.eventData.Subject );
            for (let property in result.RelatedTo) {
                options.push({
                    label : result.RelatedTo[property],
                    value : property
                });
            }
            for (let property in result.Name) {
                nameOptions.push({
                    label : result.Name[property],
                    value : property
                });
            }
            for (let property in result.Subject) {
                subjectOptions.push({
                    label : result.Subject[property],
                    value : property
                });
                console.log('isSubjectInPicklist 1 ===', isSubjectInPicklist);
                if(!isSubjectInPicklist) {
                    isSubjectInPicklist = (result.Subject[property] == this.eventData.Subject);
                }
                console.log('isSubjectInPicklist 2 ===', isSubjectInPicklist);

            }
            for (let property in result.Type) {
                typeOptions.push({
                    label : result.Type[property],
                    value : property
                });
            }
            for (let property in result.ShowAs) {
                showAsOptions.push({
                    label : result.ShowAs[property],
                    value : property
                });
            }
            if(!isSubjectInPicklist) {
                subjectOptions.push({
                    label : this.eventData.Subject,
                    value : this.eventData.Subject
                });
            }
            this.nameObjectOptions = nameOptions;
            this.relatedToOptions = options;
            this.subjectOptions = subjectOptions;
            this.typeOptions = typeOptions;
            this.showAsOptions = showAsOptions;
        }).catch(error => {
            this.notifyUser('Init Error', 'An error occured while getting the data for picklists', 'error');
            console.error('Init error', JSON.stringify(error));
            this.errors = [error]; 
        })
    }

    /******************************************************
     * handlers for input fields changes
     *****************************************************/
    handleChange(event) {
        this.relatedToObject = event.detail.value;
    }

    handleNameObjectChange(event) {
        this.nameObject = event.detail.value;
    }

    handleSubjectChange(event) {
        this.eventData.Subject = event.detail.value;
    }

    handleTypeChange(event) {
        this.eventData.Type = event.detail.value;
    }

    handleDescriptionChange(event) {
        this.eventData.Description = event.target.value;
    }

    handleStartChange(event) {
        this.eventData.StartDateTime = event.target.value;
    }

    handleEndChange(event) {
        this.eventData.EndDateTime = event.target.value;
    }

    handlePrivateChange(event) {
        this.eventData.IsPrivate = event.target.checked;
    }

    handleIsAllDayChange(event) {
        this.eventData.IsAllDayEvent = event.target.checked;
    }

    handleLocationChange(event) {
        this.eventData.Location = event.target.value;
    }

    handleShowAsChange(event) {
        this.eventData.ShowAs = event.target.value;
    }

    handleIsReminderChange(event) {
        this.eventData.IsReminderSet = event.target.checked;
    }
   
    handleWhatIdChange(event) {
        this.relatedToRecord = event.target.getSelection();
        this.checkForErrors(event, this.whatIdErrors);
    }

    handleWhoIdChange(event) {
        this.nameRecord = event.target.getSelection();
        this.checkForErrors(event, this.whoIdErrors);
    }

    handleUserChange(event) {
        this.ownerRecord = event.target.getSelection();
        this.checkForErrors(event, this.ownerIderrors);
    }

    /************************************************
     * close modal window button handler
     *************************************************/
    closeModal(event) {
        this.dispatchEvent(new CustomEvent('Close'));
    }
}