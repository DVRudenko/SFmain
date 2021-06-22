trigger LeadTrigger on Lead(after delete, after insert, after undelete, after update, before delete,
        before insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        //save formatted phone numbers
        LeadHandler.unifyPhoneNumbers(Trigger.new);
    }

    if (LeadHandler.enablesTrigger && LeadHandler.context == LeadHandler.TriggerContext.STANDARD.name()) {
        if (Trigger.isBefore && Trigger.isInsert) {

            LeadHandler.setCCSSalesProcessRecordType(Trigger.new, null);

            // Remove + from the number of cards facebook
            LeadHandler.prepareFacebookNumberOfCards(Trigger.new);

            // Parse Shell email
            LeadHandler.prepareShellEmailLead(Trigger.new);

            // Set Russian Sales Record Type
            LeadHandler.setRecordType(Trigger.new);

            // Validate Mobile Phone
            LeadHandler.validateMobilePhone(null, Trigger.new);

            // assign new lead based on rules and active users
            LeadRelocationService.customLeadAssign(Trigger.new);

            // //Set default value to Last Owner Change Date
            LeadHandler.updateFirstLastOwnerDate(Trigger.new);

            //Populate CCS Telesales Operator field
            LeadHandler.populateCCSTelesalesOperator(null, Trigger.new);

            // process field values
            LeadHandler.setFields(null, Trigger.new);

            // Set Status for Russia
            LeadHandler.setStatusForRecordType(Trigger.new);

            /*add Ilya Garin 13.10.2017 Set default value to Last Owner Change Date RUS*/
            LeadHandler.insertLastOwnerChangeDateRUS(Trigger.new);

            // Finding lead duplicates of AllStar short form
            LeadHandler.searchAllStarShortFormLeadDuplicates(Trigger.new);

            // Disqualify leads with specific email addresses
            LeadHandler.disqualifySpecificLeads(Trigger.new);

            //Update the CurrencyIsoCode by countryCode
            LeadHandler.updateCurrencyIsoCode(null, Trigger.new);

            //update field for azs shell after insert
            LeadHandler.updateLeadAZSShellOne(Trigger.new);

            //if inserted Lead_and_Opp_For_Dedublication__c
            LeadHandler.updateRelatedLeadInDeduplication(null, Trigger.new);

            //set Region__c and Area__c based on OKATO__c
            LeadHandler.setRecordAddressFromOKATO(null, Trigger.new);

            //check OZ number with oz_number_checker__c list
            LeadHandler.CheckOzNumberUpdateOwner(null, Trigger.new);

            // set account partner relationship
            LeadHandler.setPartnerRelationship(Trigger.new);

            //SF-SF-1314 Chat Leads reassign
            LeadHandler.chatLeadsAssign(Trigger.new);

            LeadHandler.executeLeadDeduplication(Trigger.new);

            LeadHandler.setMarketoSyncFlag(null, Trigger.new);
        }

        if (Trigger.isBefore && Trigger.isUpdate) {
            //All before update actions (optimization for bulk).
            LeadHandler.setAccountHomeStation(Trigger.oldMap, Trigger.newMap);

            LeadHandler.setCCSSalesProcessRecordType(Trigger.new, Trigger.oldMap);

            // Validate Mobile Phone
            LeadHandler.validateMobilePhone(Trigger.oldMap, Trigger.new);

            // Сhecking active Lead Relocation Batch if changing lead status from "Open"
            // LeadHandler.activeLeadRelocationBatchChecker(Trigger.oldMap, Trigger.newMap);

            // assign new lead based on rules and active users
            LeadRelocationService.customLeadAssignExternalForm(Trigger.oldMap, Trigger.newMap);

            //Update Last Owner Change Date field
            LeadHandler.updateLastOwnerDate(Trigger.oldMap, Trigger.newMap);

            //Fill first call for leads
            LeadHandler.makeFirstCall(Trigger.oldMap, Trigger.newMap);

            //Create new Task for Contacted status and clear "Next" fields
            LeadHandler.createTaskForContacted(Trigger.oldMap, Trigger.newMap);

            //Populate CCS Telesales Operator field
            LeadHandler.populateCCSTelesalesOperator(Trigger.oldMap, Trigger.new);

            // process field values
            LeadHandler.setFields(Trigger.oldMap, Trigger.new);

            //Update "OLD Quali Status", "OLD Service: Other (specific)", "OLD Why not interested?" fields if Lead Status = "Disqualified".
            LeadHandler.updateDisqualifiedLeadFields(Trigger.oldMap, Trigger.newMap);

            //send request to Emarsys
            EmarsysHandler.sendContactsToEmarsys(Trigger.oldMap, Trigger.newMap, 'RU&EU');

            /*add Ilya Garin 14.11.2017 Update Last_Date_Change_Owner_RUS in Lead*/
            LeadHandler.updateBeforeLastOwnerChangeDateRUS(Trigger.oldMap, Trigger.newMap);

            //calculating lead processing time (Lead Processing Time field)
            LeadHandler.calculateLeadProcessingTime(Trigger.oldMap, Trigger.newMap);

            //Update the CurrencyIsoCode by countryCode
            LeadHandler.updateCurrencyIsoCode(Trigger.oldMap, Trigger.new);

            //update fields for azs shell
            LeadHandler.updateLeadAZSShellOneTwo(Trigger.oldMap, Trigger.newMap);

            //change Open_Task__c after changing oppty owner
            LeadHandler.updateOpenTaskCheckbox(Trigger.oldMap, Trigger.newMap);

            //if inserted Lead_and_Opp_For_Dedublication__c
            LeadHandler.updateRelatedLeadInDeduplication(Trigger.oldMap, Trigger.new);

            //set penalty rating for refused Opportunity
            LeadHandler.setPenaltyRating(Trigger.oldMap, Trigger.newMap);

            //set Region__c and Area__c based on OKATO__c
            LeadHandler.setRecordAddressFromOKATO(Trigger.oldMap, Trigger.new);

            //calculate Total Consumption or Amount fields according to fuel prices
            LeadHandler.calculateTotalConsumptionBasedOnAmount(Trigger.oldMap, Trigger.new);

            LeadHandler.setMarketoSyncFlag(Trigger.oldMap, Trigger.new);
        }
        if (Trigger.isBefore && Trigger.isDelete) {
            LeadHandler.finishNaumenCasesForLeadsList (Trigger.old);
        }

        if (Trigger.isAfter && Trigger.isInsert) {

            //update fields from RegonAPI
            LeadHandler.setValuesFromRegionApi(null, Trigger.new);

            //switch to e2e
            LeadHandler.switchToE2E(null, Trigger.newMap);

            //Send email to assignee
//            LeadRelocationService.sendLeadAssignEmail(Trigger.newMap);

            //e-mail notification if a Customer that already exists in SF database as an Opportunity in non-terminal stage (Stage ≠ Closed Won) or as a Lead in any Lead Status, tries to submit a new Short
            LeadHandler.sendEmailLeadDuplicatesAllStarShortForm(Trigger.new);

            //Merge chat leads
            LeadHandler.mergeChatLead(Trigger.newMap);

            //send request to Emarsys and create contact
            EmarsysHandler.sendContactsToEmarsys(null, Trigger.newMap, 'RU');

            //SF-SF-1249 Chat Leads reassign
            LeadHandler.chatEmailSending(Trigger.newMap);
        }

        if (Trigger.isAfter && Trigger.isUpdate) {

            //update fields from RegonAPI
            LeadHandler.setValuesFromRegionApi(Trigger.oldMap, Trigger.new);

            //switch to e2e
            LeadHandler.switchToE2E(Trigger.oldMap, Trigger.newMap);

            //Send email to assignee
            LeadRelocationService.sendLeadAssignEmail(Trigger.newMap, Trigger.oldMap);

            //Assign Partner for Opportunity after Leads convertation
            LeadHandler.assignPartnerforOpportunity(Trigger.oldMap, Trigger.newMap);

            //Update CCS information after convert
            LeadHandler.updateCCS(Trigger.oldMap, Trigger.newMap);

            /*add Ilya Garin 13.10.2017 Update Last_Date_Change_Owner_RUS in Opportunity*/
            LeadHandler.updateLastOwnerChangeDateRUS(Trigger.new, Trigger.oldMap);

            //set Primary_Contact_Phone__c field in Opportunity during conversion lead
            LeadHandler.setPrimaryContactPhoneField(Trigger.newMap, Trigger.oldMap);

            //close Task associated with Lead after Status changed to Disqualify
            if (LeadHandler.isLeadClosed) {
                LeadHandler.closeTasksAfterLeadClosed(Trigger.new, Trigger.newMap);
            }

            //check OZ number with oz_number_checker__c list
            LeadHandler.CheckOzNumberUpdateOwner(Trigger.oldMap, Trigger.new);
        }
    } else if (LeadHandler.context == LeadHandler.TriggerContext.DISTRIBUTION_ENGINE.name()) {
        if (Trigger.isBefore && Trigger.isUpdate) {
            LeadHandler.updateLastOwnerDate(Trigger.oldMap, Trigger.newMap);

            LeadHandler.populateCCSTelesalesOperator(Trigger.oldMap, Trigger.new);

            LeadHandler.updateBeforeLastOwnerChangeDateRUS(Trigger.oldMap, Trigger.newMap);

            LeadHandler.updateOpenTaskCheckbox(Trigger.oldMap, Trigger.newMap);
        }
    }
}