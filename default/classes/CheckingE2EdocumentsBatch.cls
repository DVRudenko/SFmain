global class CheckingE2EdocumentsBatch implements Database.Batchable<sObject>, Database.Stateful {
    public String query;
    private String errorsLog;
    private List<Health_Check__c> healthCheckToInsertList;

    global CheckingE2EdocumentsBatch() {
        this.query = 'SELECT Id, Name, Account.BillingCountry, E2E_Active_Step__c, E2E_Active_Substep__c, Device_Type__c, ' + 
                         'Agree_to_VAT_Recovery_TC__c, SEPA_Request_Approved__c, Security_Amount_To_Pay__c, E2E_Errors__c, ' +
                         '(SELECT Id, Name, ParentId FROM Attachments) ' +
                     'FROM Opportunity WHERE CreatedDate >= LAST_N_DAYS:1';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
        this.healthCheckToInsertList = new List<Health_Check__c>();
        this.errorsLog = '';
        for (Sobject sobj : scope) {
            Opportunity oppty = (Opportunity) sobj;
            String caseName;
            if (oppty.Account.BillingCountry == 'Germany') {
                caseName = returnCaseNumberForGermany(oppty);
            } else if (oppty.Account.BillingCountry == 'Austria') {
                caseName = returnCaseNumberForAustria(oppty);
            } else if (oppty.Account.BillingCountry == 'Netherlands') {
                caseName = returnCaseNumberForNetherlands(oppty);
            } else if (oppty.Account.BillingCountry == 'Poland') {
                caseName = returnCaseNumberForPoland(oppty);
            } else if (oppty.Account.BillingCountry == 'Hungary') {
                caseName = returnCaseNumberForHungary(oppty);
            } else if (oppty.Account.BillingCountry == 'Belgium-NL' || oppty.Account.BillingCountry == 'Belgium-FR') {
                caseName = returnCaseNumberForBelgium(oppty);
            } else if (oppty.Account.BillingCountry == 'Switzerland-DE' || oppty.Account.BillingCountry == 'Switzerland-FR') {
                caseName = returnCaseNumberForSwitzerland(oppty);
            } else if (oppty.Account.BillingCountry == 'France') {
                caseName = returnCaseNumberForFrance(oppty);
            }
            String finalCaseKey = oppty.Account.BillingCountry + '_' + caseName;
            if (casesWithDocNamesPatternMap.containsKey(finalCaseKey)) {
                doCheckDocuments(oppty, casesWithDocNamesPatternMap.get(finalCaseKey));
            }
        }
        if (! this.healthCheckToInsertList.isEmpty()) insert this.healthCheckToInsertList;
    }


    global void finish(Database.BatchableContext BC) {
        if (this.errorsLog != '') {
            this.errorsLog = '<p>The following records are missing documents: </p>' + this.errorsLog;
            E2E_Docs_Check_Settings__c notificationsSetting = E2E_Docs_Check_Settings__c.getInstance('Email Notifications');
            if (notificationsSetting != null) {
                List<String> recipientsList = new List<String>();
                recipientsList.addAll(notificationsSetting.Email_Recipients__c.split(','));
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(recipientsList);
                mail.setSubject('Report on missing E2E documents');
                mail.setHtmlBody(this.errorsLog); 
                if (! Test.isRunningTest()) {
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                } 
            }   
        }
    }


    private void doCheckDocuments(Opportunity oppty, Set<String> docNamesPatternSet) {
        Set<String> existingAttachNamesSet = new Set<String>();
        for (Attachment attach : oppty.Attachments) {
            existingAttachNamesSet.add(attach.Name);
        }
        String missingDocuments = '';
        for (String requiredAttachName : docNamesPatternSet) {
            if (! existingAttachNamesSet.contains(requiredAttachName)) missingDocuments += requiredAttachName + ', '; 
        }        
        if (missingDocuments != '') {
            missingDocuments = missingDocuments.removeEnd(', ');
            this.errorsLog += '<p>Opportunity Name: <a href="' + System.URL.getSalesforceBaseURL().toExternalForm() + '/' + oppty.Id + '">' + oppty.Name + '</a><br/>' +
                            'Step/Substep: ' + oppty.E2E_Active_Step__c + ' / ' + oppty.E2E_Active_Substep__c + '<br/>' +
                            'Missing Documents: ' + missingDocuments + '</p>';

            Health_Check__c newHealthCheck = new Health_Check__c();
            newHealthCheck.Name = 'There is no document!';
            newHealthCheck.Description__c = 'For ' + oppty.E2E_Active_Step__c + ' step and ' + oppty.E2E_Active_Substep__c + ' substep the following documents are missing: \n' + missingDocuments;
            newHealthCheck.Device__c = oppty.Device_Type__c;
            newHealthCheck.Opportunity__c = oppty.Id;
            newHealthCheck.Country__c = oppty.Account.BillingCountry;
            this.healthCheckToInsertList.add(newHealthCheck);
        }
    }


    private String returnCaseNumberForGermany(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score' || activeSubstep == 'Enter Tax ID') return 'CASE_1';
        } else if (activeStep == 2 || activeStep == 3) {
            return 'CASE_1';
        } else if (activeStep == 4) {
            if (activeSubstep == 'DirectDebit' || activeSubstep == 'BankTransfer' || activeSubstep == 'BankTransferDeposit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                return 'CASE_1';
            } else if (activeSubstep == 'DirectDebitDeposit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_4';
                return 'CASE_3';
            }
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_5';
                    return 'CASE_6';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_7';
                    return 'CASE_8';
                }
            } else {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_4';
                    return 'CASE_3';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                    return 'CASE_1';
                }
            }
        }
        return null;
    }


    private String returnCaseNumberForAustria(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score' || activeSubstep == 'Enter Tax ID') return 'CASE_1';
        } else if (activeStep == 2 || activeStep == 3) {
            return 'CASE_1';
        } else if (activeStep == 4) {
            if (activeSubstep == 'DirectDebit' || activeSubstep == 'BankTransfer' || activeSubstep == 'BankTransferDeposit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                return 'CASE_1';
            } else if (activeSubstep == 'DirectDebitDeposit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_4';
                return 'CASE_3';
            }
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_5';
                    return 'CASE_6';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_7';
                    return 'CASE_8';
                }
            } else {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_4';
                    return 'CASE_3';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                    return 'CASE_1';
                }
            }
        }
        return null;
    }


    private String returnCaseNumberForNetherlands(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score' || activeSubstep == 'Enter VAT Number') return 'CASE_1';
        } else if (activeStep == 2 || activeStep == 3) {
            return 'CASE_1';
        } else if (activeStep == 4) {
            if (activeSubstep == 'DirectDebit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                return 'CASE_1';
            } else if (activeSubstep == 'DirectDebitDeposit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_3';
                return 'CASE_4';
            }
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_5';
                    return 'CASE_6';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_7';
                    return 'CASE_8';
                }
            } else {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_3';
                    return 'CASE_4';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                    return 'CASE_1';
                }
            }
        }
        return null;
    }


    private String returnCaseNumberForPoland(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score' || activeSubstep == 'Enter VAT Number') {
                return 'CASE_1';
            } else if (oppty.E2E_Errors__c != null && activeSubstep == 'Additional Credit Scoring Allowance' && oppty.E2E_Errors__c.contains('Too high limit. Additional Credit Scoring Allowance')) {
                return 'CASE_2';
            }
        } else if (activeStep == 2) {
            return 'CASE_1';
        } else if (activeStep == 3) {
            if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_3';
            return 'CASE_1';
        } else if (activeStep == 4) {
            if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_4';
            return 'CASE_5';
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_4';
                return 'CASE_5';
            } else {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_6';
                return 'CASE_7';
            }
        }
        return null;
    }


    private String returnCaseNumberForHungary(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score') return 'CASE_1';
        } else if (activeStep == 2 || activeStep == 3) {
            return 'CASE_1';
        } else if (activeStep == 4) {
            return 'CASE_2';
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) {
                return 'CASE_2';
            } else {
                return 'CASE_3';
            }
        }
        return null;
    }


    private String returnCaseNumberForBelgium(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score' || activeSubstep == 'Enter VAT Number') return 'CASE_1';
        } else if (activeStep == 2 || activeStep == 3) {
            return 'CASE_1';
        } else if (activeStep == 4) {
            if (activeSubstep == 'DirectDebit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                return 'CASE_1';
            } else if (activeSubstep == 'DirectDebitDeposit') {
                if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_3';
                return 'CASE_4';
            }
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_5';
                    return 'CASE_6';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_7';
                    return 'CASE_8';
                }
            } else {
                if (oppty.SEPA_Request_Approved__c == true) {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_3';
                    return 'CASE_4';
                } else {
                    if (oppty.Agree_to_VAT_Recovery_TC__c == true) return 'CASE_2';
                    return 'CASE_1';
                }
            }
        }
        return null;
    }   


    private String returnCaseNumberForSwitzerland(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score' || activeSubstep == 'Enter Tax ID') return 'CASE_1';
        } else if (activeStep == 2 || activeStep == 3 || activeStep == 4) {
            return 'CASE_1';
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) return 'CASE_2';
            return 'CASE_1';
        }
        return null;
    }


    private String returnCaseNumberForFrance(Opportunity oppty) {
        Decimal activeStep = oppty.E2E_Active_Step__c;
        String activeSubstep = oppty.E2E_Active_Substep__c;
        if (activeStep == 1) {
            if (activeSubstep == 'Set total consumption' || activeSubstep == 'Calculating credit score' || activeSubstep == 'Enter VAT Number') return 'CASE_1';
        } else if (activeStep == 2 || activeStep == 3) {
            return 'CASE_1';
        } else if (activeStep == 4) {
            if (activeSubstep == 'DirectDebit') {
                return 'CASE_1';
            } else if (activeSubstep == 'DirectDebitDeposit') {
                return 'CASE_2';
            }
        } else if (activeStep == 5) {
            if (oppty.Security_Amount_To_Pay__c != null) {
                if (oppty.SEPA_Request_Approved__c == true) return 'CASE_3';
                return 'CASE_4';
            } else {
                if (oppty.SEPA_Request_Approved__c == true) return 'CASE_2';
                return 'CASE_1';
            }
        }
        return null;
    }


    private Map<String, Set<String>> casesWithDocNamesPatternMap = new Map<String, Set<String>> {
        'Germany_CASE_1' => new Set<String>{'SchufaReport.pdf'},
        'Germany_CASE_2' => new Set<String>{'SchufaReport.pdf', 'vatRecoveryTC.pdf'},
        'Germany_CASE_3' => new Set<String>{'SchufaReport.pdf', 'SEPAMandate.pdf'},
        'Germany_CASE_4' => new Set<String>{'SchufaReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf'},
        'Germany_CASE_5' => new Set<String>{'SchufaReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf', 'DepositAgreement.pdf'},
        'Germany_CASE_6' => new Set<String>{'SchufaReport.pdf', 'SEPAMandate.pdf', 'DepositAgreement.pdf'},
        'Germany_CASE_7' => new Set<String>{'SchufaReport.pdf', 'vatRecoveryTC.pdf', 'DepositAgreement.pdf'},
        'Germany_CASE_8' => new Set<String>{'SchufaReport.pdf', 'DepositAgreement.pdf'},
        'Austria_CASE_1' => new Set<String>{'CrefoReport.pdf'},
        'Austria_CASE_2' => new Set<String>{'CrefoReport.pdf', 'vatRecoveryTC.pdf'},
        'Austria_CASE_3' => new Set<String>{'CrefoReport.pdf', 'SEPAMandate.pdf'},
        'Austria_CASE_4' => new Set<String>{'CrefoReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf'},
        'Austria_CASE_5' => new Set<String>{'CrefoReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf', 'DepositAgreement.pdf'},
        'Austria_CASE_6' => new Set<String>{'CrefoReport.pdf', 'SEPAMandate.pdf', 'DepositAgreement.pdf'},
        'Austria_CASE_7' => new Set<String>{'CrefoReport.pdf', 'vatRecoveryTC.pdf', 'DepositAgreement.pdf'},
        'Austria_CASE_8' => new Set<String>{'CrefoReport.pdf', 'DepositAgreement.pdf'},
        'Netherlands_CASE_1' => new Set<String>{'CreditsafeReport.pdf'},
        'Netherlands_CASE_2' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf'},
        'Netherlands_CASE_3' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf'},
        'Netherlands_CASE_4' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf'},
        'Netherlands_CASE_5' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf', 'DepositAgreementNL.pdf'},
        'Netherlands_CASE_6' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf', 'DepositAgreementNL.pdf'},
        'Netherlands_CASE_7' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'DepositAgreementNL.pdf'},
        'Netherlands_CASE_8' => new Set<String>{'CreditsafeReport.pdf', 'DepositAgreementNL.pdf'},
        'Poland_CASE_1' => new Set<String>{'CrifReport.pdf'},
        'Poland_CASE_2' => new Set<String>{'CrifReport.pdf', 'Zgoda na weryfikację (DocuSign).pdf'},
        'Poland_CASE_3' => new Set<String>{'CrifReport.pdf', 'vatRecoveryTC.pdf'},
        'Poland_CASE_4' => new Set<String>{'CrifReport.pdf', 'vatRecoveryTC.pdf', 'Umowa Karty euroShell (DocuSign).pdf', 'Umowa_o_kaucji (DocuSign).pdf'},
        'Poland_CASE_5' => new Set<String>{'CrifReport.pdf', 'Umowa Karty euroShell (DocuSign).pdf', 'Umowa_o_kaucji (DocuSign).pdf'},
        'Poland_CASE_6' => new Set<String>{'CrifReport.pdf', 'vatRecoveryTC.pdf', 'Umowa Karty euroShell (DocuSign).pdf'},
        'Poland_CASE_7' => new Set<String>{'CrifReport.pdf', 'Umowa Karty euroShell (DocuSign).pdf'},
        'Hungary_CASE_1' => new Set<String>{'CofaceReport.pdf'},
        'Hungary_CASE_2' => new Set<String>{'CofaceReport.pdf', 'ContractHU.pdf', 'DepositAgreementHU.pdf'},
        'Hungary_CASE_3' => new Set<String>{'CofaceReport.pdf', 'ContractHU.pdf'},
        'France_CASE_1' => new Set<String>{'CreditsafeReport.pdf'},
        'France_CASE_2' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf'},
        'France_CASE_3' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf', 'DepositAgreementFR.pdf'},
        'France_CASE_4' => new Set<String>{'CreditsafeReport.pdf', 'DepositAgreementFR.pdf'},
        'Belgium-NL_CASE_1' => new Set<String>{'CreditsafeReport.pdf'},
        'Belgium-NL_CASE_2' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf'},
        'Belgium-NL_CASE_3' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf'},
        'Belgium-NL_CASE_4' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf'},
        'Belgium-NL_CASE_5' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf', 'DepositAgreementBENL.pdf'},
        'Belgium-NL_CASE_6' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf', 'DepositAgreementBENL.pdf'},
        'Belgium-NL_CASE_7' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'DepositAgreementBENL.pdf'},
        'Belgium-NL_CASE_8' => new Set<String>{'CreditsafeReport.pdf', 'DepositAgreementBENL.pdf'},
        'Belgium-FR_CASE_1' => new Set<String>{'CreditsafeReport.pdf'},
        'Belgium-FR_CASE_2' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf'},
        'Belgium-FR_CASE_3' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf'},
        'Belgium-FR_CASE_4' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf'},
        'Belgium-FR_CASE_5' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'SEPAMandate.pdf', 'DepositAgreementBEFR.pdf'},
        'Belgium-FR_CASE_6' => new Set<String>{'CreditsafeReport.pdf', 'SEPAMandate.pdf', 'DepositAgreementBEFR.pdf'},
        'Belgium-FR_CASE_7' => new Set<String>{'CreditsafeReport.pdf', 'vatRecoveryTC.pdf', 'DepositAgreementBEFR.pdf'},
        'Belgium-FR_CASE_8' => new Set<String>{'CreditsafeReport.pdf', 'DepositAgreementBEFR.pdf'},
        'Switzerland-DE_CASE_1' => new Set<String>{'CrediconnectReport.pdf'},
        'Switzerland-DE_CASE_2' => new Set<String>{'CrediconnectReport.pdf', 'DepositAgreementCHDE.pdf'},
        'Switzerland-FR_CASE_1' => new Set<String>{'CrediconnectReport.pdf'},
        'Switzerland-FR_CASE_2' => new Set<String>{'CrediconnectReport.pdf', 'DepositAgreementCHFR.pdf'}
    };
}