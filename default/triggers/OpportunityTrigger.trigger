trigger OpportunityTrigger on Opportunity(after delete, after insert, after undelete, after update, before delete,
        before insert, before update) {
    if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
        OpportunityTriggerHandler.processOpportunityScoring(Trigger.new, Trigger.oldMap, Trigger.isUpdate);
    }

    if (Trigger.isBefore && Trigger.isUpdate && OpportunityTriggerHandler.isE2EForm) {
        OpportunityTriggerHandler.isE2EForm = false;

        //Update Last Owner Change Date field
        OpportunityTriggerHandler.updateLastOwnerDate(Trigger.oldMap, Trigger.newMap);

        // send request to Emarsys
        EmarsysHandler.sendContactsToEmarsys(Trigger.oldMap, Trigger.newMap, 'RU');
    }

    if (OpportunityTriggerHandler.enablesTrigger && OpportunityTriggerHandler.context == OpportunityTriggerHandler.TriggerContext.STANDARD.name()) {
        if (Trigger.isBefore && Trigger.isUpdate) {
            //get credit & other info about organization
            if ( !OpportunityTriggerHandler.isE2EForm) {
                OpportunityTriggerHandler.verifyCompany(Trigger.oldMap, Trigger.new);
            }

            OpportunityTriggerHandler.finishE2E2Process(Trigger.oldMap, Trigger.newMap);

            OpportunityTriggerHandler.opportunityBeforeUpdate(Trigger.oldMap, Trigger.newMap);

            OpportunityTriggerHandler.setAccountHomeStation(Trigger.oldMap, Trigger.newMap);

            //change opportunity stage name from Pending Sales - SEPA Confirmation(exposed by Credit Factory) to Closed Won
            OpportunityTriggerHandler.changeToClosedWonAfterPendingSepa(Trigger.oldMap, Trigger.newMap);

            //update starts fields when opportunity is closed
            OpportunityTriggerHandler.updateStartsFieldsAfterClosedWon(Trigger.oldMap, Trigger.newMap);

            //update starts schedule value when starts status is changed
            OpportunityTriggerHandler.startsSLAcalculate(Trigger.oldMap, Trigger.newMap);

            // send request to Emarsys
            EmarsysHandler.sendContactsToEmarsys(Trigger.oldMap, Trigger.newMap, 'RU&EU');

            /*add Ilya Garin 13.10.2017*/
            OpportunityTriggerHandler.updateLastOwnerChangeDateRUS(Trigger.oldMap, Trigger.newMap);

            //add Ilya Ivonin 08.11.2017 || request for change owner of opportunity
            OpportunityTriggerHandler.sendRequestForChangeOwnerRu(Trigger.oldMap, Trigger.newMap);

            //Update the CurrencyIsoCode in Opportunity
            OpportunityTriggerHandler.updateCurrencyIsoCode(Trigger.oldMap, Trigger.new);

            //update shell azs station fields
            OpportunityTriggerHandler.updateOpportunityAZSShellOneTwo(Trigger.oldMap, Trigger.newMap);

            // Add error for Credit if primary contact does not have valide email, incorrect details, Credit Decision is not "Endorsed" or "Endorsed, guarantee delivered"
            OpportunityTriggerHandler.addErrorForCredit(Trigger.oldMap, Trigger.new);

            // Set Close Date
            OpportunityTriggerHandler.setCloseDate(Trigger.oldMap, Trigger.newMap);

            //change Open_Task__c after changing oppty owner
            OpportunityTriggerHandler.updateOpenTaskCheckbox(Trigger.oldMap, Trigger.newMap);

            // Update E2E fields
            OpportunityTriggerHandler.updateE2EFields(Trigger.oldMap, Trigger.new);

            // Update required for vat recovery fields or display an error if they are empty
            OpportunityTriggerHandler.updateFieldsForVatRecovery(Trigger.oldMap, Trigger.newMap);

            //set penalty rating for refused Opportunity
            OpportunityTriggerHandler.setPenaltyRating(Trigger.oldMap, Trigger.newMap);

            // Set NVM fields
            OpportunityTriggerHandler.setFieldsNVM(Trigger.new);

            //block user if Files are missing under Opportunity
            OpportunityTriggerHandler.validateCarnetOpportunity(Trigger.oldMap, Trigger.newMap);

            // Approve changing type of oppo with account.AccountStatus
            OpportunityTriggerHandler.carnetOpportunityTypeStatus(Trigger.oldMap, Trigger.newMap);

            // block not allowed checking of Deposit_Amount__c value if type of payment is not correct
            OpportunityTriggerHandler.carnetOpportunityDepositAmountCheck(Trigger.oldMap, Trigger.newMap);

            // block unauthorized changing status as Closed won
            OpportunityTriggerHandler.carnetOpportunitySaveClosedWonPayment(Trigger.oldMap, Trigger.newMap);

            // block unauthorized changing status as Closed won/lost
            OpportunityTriggerHandler.carnetOpportunityProfileRolesClosing(Trigger.oldMap, Trigger.newMap);

            // update Opportunity processing time
            OpportunityTriggerHandler.calculateOpportunityProcessingTime(Trigger.oldMap, Trigger.newMap);

            // check changes of non-fuel exposure in processed opportunity.
            OpportunityTriggerHandler.checkNonFuelExposureChanges(Trigger.oldMap, Trigger.new);

            OpportunityTriggerHandler.checkCreditToApproveOpportunity(Trigger.oldMap, Trigger.newMap);

            //calculate Total Consumption or Amount fields according to fuel prices
            OpportunityTriggerHandler.calculateTotalConsumptionBasedOnAmount(Trigger.oldMap, Trigger.new);

            // Before Update CCS Opportunity method
            OpportunityTriggerHandler.updateCCSOpportunity(Trigger.oldMap, Trigger.new);

            //Locking Closed Opportunities
            OpportunityTriggerHandler.lockingClosedOpportunities(Trigger.oldMap, Trigger.newMap);

            //Locking CCS Opportunities with CCS Order under them
            OpportunityTriggerHandler.ccsOpportunityLockOrder(Trigger.oldMap, Trigger.newMap);
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            //set Standard business process if manual Russian Opportunity
            if (OpportunityTriggerHandler.enablesTrigger && !OpportunityTriggerHandler.isE2EForm) {
                OpportunityTriggerHandler.setOpportunityStandardBusinessProcess(Trigger.new);
            }
            //Capitalize fields
            OpportunityTriggerHandler.maketouppercase(Trigger.new);

            //Set default value to Last Owner Change Date
            OpportunityTriggerHandler.updateFirstLastOwnerDate(Trigger.new);

            // Set AllStar and Russian Sales Record Type
            OpportunityTriggerHandler.setRecordType(Trigger.new);

            // update fields on converting Lead to Opportunity
            OpportunityTriggerHandler.updateFieldsOnConvert(Trigger.new);

            // Set Opportunity Stage Name
            OpportunityTriggerHandler.setOpporunityStageName(Trigger.new);

            /*add Ilya Garin 13.10.2017*/
            OpportunityTriggerHandler.insertLastOwnerChangeDateRUS(Trigger.new);

            //add Ilya Ivonin 08.11.2017 || request for change owner of opportunity
            OpportunityTriggerHandler.sendRequestForCreateSecondOpportunity(Trigger.new);

            //Set Stage name equals Prospecting if Opportunity is clone
            OpportunityTriggerHandler.setOpptyFieldsForClone(Trigger.new);

            //Update the CurrencyIsoCode in Opportunity
            OpportunityTriggerHandler.updateCurrencyIsoCode(null, Trigger.new);

            //update AZS shel station fields
            OpportunityTriggerHandler.updateOpportunityAZSShellOne(Trigger.new);

            // Update E2E fields
            OpportunityTriggerHandler.updateE2EFields(null, Trigger.new);

            // Check that Account doesn't already have Opportunity created in the last 31 days with the same record type
            OpportunityTriggerHandler.checkAccountOpportunities(Trigger.new);

            // Set NVM fields
            OpportunityTriggerHandler.setFieldsNVM(Trigger.new);

            //check OZ number with oz_number_checker__c list
            OpportunityTriggerHandler.CheckOzNumberUpdateOwner(null, Trigger.new);

            // Before Insert CCS Opportunity
            OpportunityTriggerHandler.updateCCSOpportunity(null, Trigger.new);

            //calculate Total Consumption or Amount fields according to fuel prices
            OpportunityTriggerHandler.calculateTotalConsumptionBasedOnAmount(null, Trigger.new);
        }
        if (Trigger.isBefore && Trigger.isDelete) {
            OpportunityTriggerHandler.finishNaumenCasesForOpportunitiesList (Trigger.old);
        }

        if (Trigger.isAfter && Trigger.isUpdate) {
            //change owner for Credit_factory_report__c Russian records
            OpportunityTriggerHandler.changeRussianCreditFactoryReportsOwner(Trigger.newMap);

            //Send Welcome Email
            OpportunityTriggerHandler.sendWelcomeEmail(Trigger.oldMap, Trigger.newMap);

            //Send Email Notification to BackOffice (Starts Process)
            OpportunityTriggerHandler.sendEmailToBackOffice(Trigger.oldMap, Trigger.newMap);

            //Send Email Notification to Opportunity Owner (Starts Process)
            OpportunityTriggerHandler.sendEmailToStartsOpptyOwner(Trigger.oldMap, Trigger.newMap);

            //Update Vouchers Sent Field (+1)
            OpportunityTriggerHandler.updateVouchersSentField(Trigger.oldMap, Trigger.newMap);

            //Send Fleetmatics email
            OpportunityTriggerHandler.sendToFleetmatics(Trigger.oldMap, Trigger.newMap);

            //Send report to GFN if Starts_Status__c changed to "Ready for GFN"
            OpportunityTriggerHandler.sendAccountReportToBackOffice(Trigger.oldMap, Trigger.newMap);

            //Send notification to Teamleaders if Sales Agent updates Total_consumption_l_month__c field 3 and more times in the same Opportunity
            OpportunityTriggerHandler.sendTotalConsumptionChangeAlert(Trigger.oldMap, Trigger.newMap);

            //creating task if Starts Status = 0.5 Missing information
            OpportunityTriggerHandler.doCreateTaskMissingInformationToStartsProcess(Trigger.oldMap, Trigger.newMap);

            //checks if Opportunity's status changed to 'Closed Lost' and closes its current Tasks
            OpportunityTriggerHandler.closeTasksAfterOpportunityClosed(Trigger.new, Trigger.newMap);

            // Approve signed Opportunities
            OpportunityTriggerHandler.approveSignedOpportunities(Trigger.oldMap, Trigger.new);

            // Update GFN number in account when GFN number in opportunity is changed
            OpportunityTriggerHandler.updateAccountGFNNumber(Trigger.oldMap, Trigger.newMap);

            // Populate Deposit fields on Carnet Opportunity
            OpportunityTriggerHandler.carnetDepositReceived(Trigger.oldMap, Trigger.newMap);

            // Update Account fields after Carnet Opportunity StageName is won
            OpportunityTriggerHandler.carnetStatusClosed(Trigger.oldMap, Trigger.newMap);

            // Populate Account Status on Opportunity after Closed Won.
            OpportunityTriggerHandler.carnetOpportunityClosedWon(Trigger.oldMap, Trigger.newMap);

            // Send Welcome Email after Shell Universal Card Opportunity is Closed Won.
            OpportunityTriggerHandler.sendWelcomeEmailShellCardPlusTravel(Trigger.oldMap, Trigger.newMap);

            // Send BO notification after CCS Opportunity from Merlin is Closed Won.
            OpportunityTriggerHandler.sendCCSBOClosedWonNotification(Trigger.oldMap, Trigger.newMap);

            // enforce user checks Opportunity Type and Starts: GFN
            //OpportunityTriggerHandler.ccsOpportunityTypeGFNCheck(Trigger.oldMap, Trigger.newMap);

            // Send email to robot for CCS Order
            OpportunityTriggerHandler.ccsOrderRobot(Trigger.oldMap, Trigger.newMap);

            // Send Welcome Email after Lotos Opportunity is Closed Won.
            OpportunityTriggerHandler.sendWelcomeEmailLotos(Trigger.oldMap, Trigger.newMap);

            //check OZ number with oz_number_checker__c list
            OpportunityTriggerHandler.CheckOzNumberUpdateOwner(Trigger.oldMap, Trigger.new);

            //Check if Opportunity Owner has changed and then modify related CCS Order
            OpportunityTriggerHandler.checkCCSOpportunityOwner(Trigger.oldMap, Trigger.new);

            // Update Account__c in OpportunityLineItems and Client_Offer_Additional_Service__c when AccountId in opportunity is changed
            OpportunityTriggerHandler.updateAccountLookup(Trigger.oldMap, Trigger.newMap);

            // Send Welcome Email after OMV Opportunity is Closed Won.
            OpportunityTriggerHandler.sendWelcomeEmailOMV(Trigger.oldMap, Trigger.newMap);
        }

        if (Trigger.isAfter && Trigger.isInsert) {
            //get credit & other info about organization
            if (OpportunityTriggerHandler.enablesTrigger && !OpportunityTriggerHandler.isE2EForm) {
                OpportunityTriggerHandler.verifyCompany(Trigger.new);
            }

            //add Ilya Ivonin 08.11.2017 || request for change owner of opportunity
            OpportunityTriggerHandler.sendRequestForCreateSecondOpportunity(Trigger.new);

            //Add Attachment, Contact role and fuel card to clone Opportunity
            OpportunityTriggerHandler.addSubjectsToCloneOpportunity(Trigger.new);

            // Set CloseDate = TODAY on CCS Opportunity if isClosed = true
            OpportunityTriggerHandler.setCloseDateCCS(Trigger.new);
        }
    } else if (OpportunityTriggerHandler.context == OpportunityTriggerHandler.TriggerContext.DISTRIBUTION_ENGINE.name()){
        if (Trigger.isBefore && Trigger.isUpdate) {
            OpportunityTriggerHandler.updateLastOwnerDate(Trigger.oldMap, Trigger.newMap);

            OpportunityTriggerHandler.updateLastOwnerChangeDateRUS(Trigger.oldMap, Trigger.newMap);

            OpportunityTriggerHandler.updateOpenTaskCheckbox(Trigger.oldMap, Trigger.newMap);
        }
        if (Trigger.isAfter && Trigger.isUpdate) {
            OpportunityTriggerHandler.changeRussianCreditFactoryReportsOwner(Trigger.newMap);

            OpportunityTriggerHandler.checkCCSOpportunityOwner(Trigger.oldMap, Trigger.new);
        }
    }
}