import { LightningElement, api, track } from "lwc";
import searchCompanies from "@salesforce/apex/CreditFactoryCtrl.searchCompanies";
import validateSearch from "@salesforce/apex/CreditFactoryCtrl.validateSearch";
import generateDataMap from "@salesforce/apex/CreditFactoryCtrl.generateDataMap";
import processCompanyNotInTheList from "@salesforce/apex/CreditFactoryCtrl.processCompanyNotInTheList";
import approveTaxId from "@salesforce/apex/CreditFactoryCtrl.approveTaxId";
import saveErrors from "@salesforce/apex/CreditFactoryCtrl.saveErrors";
import checkExistingReports from "@salesforce/apex/CreditFactoryCtrl.checkExistingReports";
import getSearchColumns from "@salesforce/apex/CreditFactoryCtrl.getSearchColumns";

export default class CreditFactorySearch extends LightningElement {
    @api opportunityId;
    @track loading;
    @track error;
    @track companiesList;
    @track errorMessage;
    @track dataMap;
    @track isContinueDisabled;
    @track searchColumnsData;
    @track isTaxIdApprove;

    async connectedCallback() {
        this.loading = true;
        this.isContinueDisabled = true;
        this.dataMap = await generateDataMap({
            opportunityId: this.opportunityId
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            this.error = true;
        });
        if (this.dataMap) {
            this.searchValidationError = await validateSearch({
                dataMap: this.dataMap
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                this.error = true;
            });
        }

        if (this.searchValidationError) {
            this.errorMessage = this.searchValidationError;
            this.error = true;
        }

        if (! this.error) {
            this.areReportsExist = await checkExistingReports({
                dataMap: this.dataMap
            })
            .catch(error => {
                this.errorMessage = error.body.message;
                this.error = true;
            });

            if (! this.areReportsExist) {
                const searchResponse = await searchCompanies({
                    dataMap: this.dataMap
                })
                .catch(error => {
                    this.errorMessage = error.body.message;
                    this.error = true;
                });

                if (searchResponse) {
                    if (! searchResponse.message) {
                        this.companiesList = searchResponse.companies;

                        const searchColumnsResponse = await getSearchColumns({
                            country: this.dataMap.country,
                        });
                        this.searchColumnsData = searchColumnsResponse;
                    }
                    else {
                        if (searchResponse.isTaxIdApprove) {
                            this.isTaxIdApprove = true;
                        }

                        this.errorMessage = searchResponse.message;
                        this.error = true;
                    }
                }
            }
            else {
                this.dispatchEvent(new CustomEvent("report", {
                    detail: {
                        selectedCompanyId: this.selectedCompanyId,
                        areReportsExist: this.areReportsExist,
                        dataMap: this.dataMap
                    },
                    bubbles: true
                }));
            }
        }

        if (this.error == true) {
            this.saveErrors();
        }

        this.loading = false;
    }

    handleBackClick() {
        this.loading = true;
        window.open("/" + this.opportunityId, "_parent");
    }

    async handleNotInTheListClick() {
        this.loading = true;
        const notInTheListResponse = await processCompanyNotInTheList({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            this.error = true;
        });
        if (notInTheListResponse && notInTheListResponse.message) {
            if (notInTheListResponse.isTaxIdApprove) {
                this.isTaxIdApprove = true;
            }

            this.errorMessage = notInTheListResponse.message;
            this.error = true;
        }

        if (this.error == true) {
            this.saveErrors();
        }

        this.loading = false;
    }

    async handleApproveTaxId() {
        this.loading = true;
        this.isTaxIdApprove = false;
        const approveTaxIdResponse = await approveTaxId({
            dataMap: this.dataMap
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            this.error = true;
        });
        if (approveTaxIdResponse && approveTaxIdResponse.message) {
            this.errorMessage = approveTaxIdResponse.message;
            this.error = true;
        }

        if (this.error == true) {
            this.saveErrors();
        }

        this.loading = false;
    }

    handleChooseCompanyClick() {
        this.loading = true;
        
        this.dispatchEvent(new CustomEvent("report", {
            detail: {
                selectedCompanyId: this.selectedCompanyId,
                areReportsExist: this.areReportsExist,
                dataMap: this.dataMap
            },
            bubbles: true
        }));
    }
    
    async saveErrors() {
        this.dataMap = await generateDataMap({
            opportunityId: this.opportunityId
        })
        .catch();
        await saveErrors({
            dataMap: this.dataMap,
            errorMessage: this.errorMessage,
            isReportGenerated: false
        })
        .catch();
    }
    
    setCompanyId(event) {
        this.isContinueDisabled = false;
        const selectedRows = event.detail.selectedRows; 
        this.selectedCompanyId = selectedRows[0].identificationNumber;
    }
}