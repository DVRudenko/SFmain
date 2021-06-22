import { LightningElement, track, api } from "lwc";
import chooseCompany from "@salesforce/apex/CreditFactoryCtrl.chooseCompany";
import selectCompany from "@salesforce/apex/CreditFactoryCtrl.selectCompany";
import getSectionsData from "@salesforce/apex/CreditFactoryCtrl.getSectionsData";
import getAddressData from "@salesforce/apex/CreditFactoryCtrl.getAddressData";
import getNameUpdateData from "@salesforce/apex/CreditFactoryCtrl.getNameUpdateData";
import getTaxIdUpdateData from "@salesforce/apex/CreditFactoryCtrl.getTaxIdUpdateData";
import getTradeRegisterNumberUpdateData from "@salesforce/apex/CreditFactoryCtrl.getTradeRegisterNumberUpdateData";
import getVatNumberUpdateData from "@salesforce/apex/CreditFactoryCtrl.getVatNumberUpdateData";
import getSwiftBicUpdateData from "@salesforce/apex/CreditFactoryCtrl.getSwiftBicUpdateData";
import setUpdateOpportunityDecision from "@salesforce/apex/CreditFactoryCtrl.setUpdateOpportunityDecision";
import changeToContractCheck from "@salesforce/apex/CreditFactoryCtrl.changeToContractCheck";
import changeToClosedWon from "@salesforce/apex/CreditFactoryCtrl.changeToClosedWon";
import changeToPendingSepa from "@salesforce/apex/CreditFactoryCtrl.changeToPendingSepa";
import changeToPendingDeposit from "@salesforce/apex/CreditFactoryCtrl.changeToPendingDeposit";
import changeToPendingAdvancePayment from "@salesforce/apex/CreditFactoryCtrl.changeToPendingAdvancePayment";
import updateContacts from "@salesforce/apex/CreditFactoryCtrl.updateContacts";
import saveErrors from "@salesforce/apex/CreditFactoryCtrl.saveErrors";
import generateDataMap from "@salesforce/apex/CreditFactoryCtrl.generateDataMap";

export default class CreditFactoryReport extends LightningElement {
    @api opportunityId;
    @api areReportsExist;
    @api selectedCompanyId;
    @track loading;
    @track error;
    @track errorMessage;
    @track dataMap;
    @track selectedCompany;
    @track additionalCompany;
    @track isReportGenerated;
    @track infoMessage;
    @track info;
    @track warningMessage;
    @track warning;
    @track isUpdateOpportunity;
    @track isPendingDeposit;
    @track isContactParentCompany;
    @track isPendingSepa;
    @track isClosedWon;
    @track isContractCheck;
    @track isPendingAdvancePayment;
    @track sectionsData;
    @track nameUpdate;
    @track addressUpdate;
    @track taxIdUpdate;
    @track tradeRegisterNumberUpdate;
    @track vatNumberUpdate;
    @track swiftBicUpdate;
    @track updateData;
    @track isInvalidAddress;
    @track isInvalidName;
    @track isInvalidTaxId;
    @track isInvalidTradeRegisterNumber;
    @track isInvalidVatNumber;
    @track isInvalidSwiftBic;
    @track isInvalidContactRole;
    
    async connectedCallback() {
        this.loading = true;
        this.dataMap = await generateDataMap({
            opportunityId: this.opportunityId
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            this.error = true;
            this.dataGenerationError = true;
        });
        
        if (! this.dataGenerationError) {
            if (this.areReportsExist) {
                this.reportResponse = await selectCompany({
                    dataMap: this.dataMap
                })
                .catch(error => {
                    this.errorMessage = error.body.message;
                    this.error = true;
                });
            }
            else {
                let isStartReportsCheck = false;
                for (let i = 0; i < 10; i++) {
                    isStartReportsCheck = i === 0;

                    this.reportResponse = await chooseCompany({
                        dataMap: this.dataMap,
                        selectedCompanyId: this.selectedCompanyId,
                        isStartReportsCheck: isStartReportsCheck
                    })
                    .catch(error => {
                        this.errorMessage = error.body.message;
                        this.error = true;
                    });

                    if (this.error || ! this.reportResponse.isWaiting) {
                        break;
                    }

                    if (i === 9) {
                        this.errorMessage = this.reportResponse.message;
                        this.error = true;
                        break;
                    }

                    await new Promise(resolve => {
                        setTimeout(resolve, 2000);
                    });
                }
            }
        }
        
        this.doScoring();
    }
    
    @api async reDoScoring() {
        this.dataMap = await generateDataMap({
            opportunityId: this.opportunityId
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            this.error = true;
            this.dataGenerationError = true;
        });

        if (! this.dataGenerationError) {
            this.reportResponse = await selectCompany({
                dataMap: this.dataMap
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                this.error = true;
            });
        }
        
        await this.doScoring();
    }
    
    async doScoring() {
        if (this.reportResponse) {
            if (! this.reportResponse.message) {
                this.selectedCompany = this.reportResponse.selectedCompany;
                this.additionalCompany = this.reportResponse.additionalCompany;
                await this.setReportFieldsToDisplay();
                this.isReportGenerated = true;
                if (this.reportResponse.failedValidations) {
                    this.isInvalidAddress = this.reportResponse.failedValidations.includes('Address');
                    this.isInvalidName = this.reportResponse.failedValidations.includes('CompanyName');
                    this.isInvalidTaxId = this.reportResponse.failedValidations.includes('TaxId');
                    this.isInvalidTradeRegisterNumber = this.reportResponse.failedValidations.includes('TradeRegisterNumber');
                    this.isInvalidVatNumber = this.reportResponse.failedValidations.includes('VatNumber');
                    this.isInvalidSwiftBic = this.reportResponse.failedValidations.includes('SwiftBic');
                    this.isInvalidContactRole = this.reportResponse.failedValidations.includes('ContactRole');
                }

                if (this.reportResponse.validationMessage) {
                    this.error = true;
                }
                else {
                    this.error = false;
                }

                if (this.reportResponse.infoMessage) {
                    this.infoMessage = this.reportResponse.infoMessage;
                    this.info = true;
                }

                if (this.reportResponse.warningMessage) {
                    this.warningMessage = this.reportResponse.warningMessage;
                    this.warning = true;
                }
                
                if (this.reportResponse.validationMessage) {
                    this.errorMessage = this.reportResponse.validationMessage;
                    this.error = true;
                }

                if (this.reportResponse.errorMessage) {
                    this.errorMessage = this.reportResponse.errorMessage;
                    this.error = true;
                }

                if (this.reportResponse.cfResult && this.reportResponse.cfResult.availableButtonsList) {
                    this.isUpdateOpportunity = this.reportResponse.cfResult.availableButtonsList.includes('Update Opportunity');
                    this.isPendingDeposit = this.reportResponse.cfResult.availableButtonsList.includes('Pending Deposit');
                    this.isContactParentCompany = this.reportResponse.cfResult.availableButtonsList.includes('Get Parent Company Employees');
                    this.isClosedWon = this.reportResponse.cfResult.availableButtonsList.includes('Closed Won');
                    this.isPendingSepa = this.reportResponse.cfResult.availableButtonsList.includes('Pending SEPA');
                    this.isContractCheck = this.reportResponse.cfResult.availableButtonsList.includes('Contract Check');
                    this.isPendingAdvancePayment = this.reportResponse.cfResult.availableButtonsList.includes('Pending Advance Payment');
                }
            } 
            else {
                this.errorMessage = this.reportResponse.message;
                this.error = true;
            }
        }
        
        if (this.error == true) {
            this.saveErrors();
        }
        
        this.loading = false;
        
        this.handleEnableButtons();
    }
    
    async saveErrors() {
         this.dataMap = await generateDataMap({
            opportunityId: this.opportunityId
        })
        .catch();
        await saveErrors({
            dataMap: this.dataMap,
            errorMessage: this.errorMessage,
            isReportGenerated: this.isReportGenerated
        })
        .catch();
    }

async setReportFieldsToDisplay() {
        const updateParameters = {
            companyData: this.selectedCompany,
            additionalCompanyData: this.additionalCompany,
            dataMap: this.dataMap
        };

        const sectionsResponse = await getSectionsData(updateParameters);
        this.sectionsData = sectionsResponse;
        
        this.addressUpdate = await getAddressData(updateParameters);
        this.nameUpdate = await getNameUpdateData(updateParameters);
        this.taxIdUpdate = await getTaxIdUpdateData(updateParameters);
        this.tradeRegisterNumberUpdate = await getTradeRegisterNumberUpdateData(updateParameters);
        this.vatNumberUpdate = await getVatNumberUpdateData(updateParameters);
        this.swiftBicUpdate = await getSwiftBicUpdateData(updateParameters);
    }
    
    handleBackClick() {
        this.loading = true;
        window.open("/" + this.opportunityId, "_parent");
    }
    
    async handleUpdateOpportunityClick() {
        this.loading = true;
        this.isDecisionFailed = false;
        
        const updateOpportunityResponse = await setUpdateOpportunityDecision({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        });
        
        if (updateOpportunityResponse) {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: updateOpportunityResponse,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        }
        
        if (this.isDecisionFailed) {
            this.saveErrors();
        }
        else {
            window.open("/" + this.opportunityId, "_parent");
        }
    }
    
    async handleContractCheckClick() {
        this.loading = true;
        this.isDecisionFailed = false;
        
        const contractCheckResponse = await changeToContractCheck({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        });
        
        if (contractCheckResponse) {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: contractCheckResponse,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        }
        
        if (this.isDecisionFailed) {
            this.saveErrors();
        }
        else {
            window.open("/" + this.opportunityId, "_parent");
        }
    }
    
    async handleClosedWonClick() {
        this.loading = true;
        this.isDecisionFailed = false;
        
        const closedWonResponse = await changeToClosedWon({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        });
        
        if (closedWonResponse) {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: closedWonResponse,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        }
        
        if (this.isDecisionFailed) {
            this.saveErrors();
        }
        else {
            window.open("/" + this.opportunityId, "_parent");
        }
    }

    async handlePendingSepaClick() {
        this.loading = true;
        this.isDecisionFailed = false;

        const pendingSepaResponse = await changeToPendingSepa({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));

            this.loading = false;
        });

        if (pendingSepaResponse) {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: pendingSepaResponse,
                    success: false
                },
                bubbles: true
            }));

            this.loading = false;
        }

        if (this.isDecisionFailed) {
            this.saveErrors();
        }
        else {
            window.open("/" + this.opportunityId, "_parent");
        }
    }
    
    async handlePendingDepositClick() {
        this.loading = true;
        
        const pendingDepositResponse = await changeToPendingDeposit({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        });
        
        if (pendingDepositResponse) {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: pendingDepositResponse,
                    success: false
                },
                bubbles: true
            }));
            
            this.loading = false;
        }
        
        if (this.isDecisionFailed) {
            this.saveErrors();
        }
        else {
            window.open("/" + this.opportunityId, "_parent");
        }
    }

    async handlePendingAdvancePaymentClick() {
        this.loading = true;

        const pendingAdvancePaymentResponse = await changeToPendingAdvancePayment({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));

            this.loading = false;
        });

        if (pendingAdvancePaymentResponse) {
            this.isDecisionFailed = true;
            this.errorMessage = console.error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: pendingAdvancePaymentResponse,
                    success: false
                },
                bubbles: false
            }));

            this.loading = false;
        }

        if (this.isDecisionFailed) {
            this.saveErrors();
        }
        else {
            window.open("/" + this.opportunityId, "_parent");
        }
    }

    async handleUpdateContactsClick() {
        this.loading = true;

        const contactParentCompanyResponse = await updateContacts({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.isDecisionFailed = true;
            this.errorMessage = error.body.message;
            this.dispatchEvent(new CustomEvent("showtoast", {
                detail: {
                    text: error.body.message,
                    success: false
                },
                bubbles: true
            }));

            this.loading = false;
        });

        if (contactParentCompanyResponse) {
            this.dispatchEvent(new CustomEvent("doscoring", {
                detail: {
                    text: contactParentCompanyResponse,
                    success: true
                },
                bubbles: true
            }));
        }
    }
    
    handleDisableButtons() {
        this.template.querySelectorAll(".report__update-item-js").forEach(element => {
            element.setIsDisabled(true);
        })
    }
    
    handleEnableButtons() {
        this.template.querySelectorAll(".report__update-item-js").forEach(element => {
            element.setIsDisabled(false);
        })
    }
}