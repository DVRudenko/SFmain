import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getOpportunityData from '@salesforce/apex/CCSMerlinOrderButtonController.getOpportunityData';
import getUserData from '@salesforce/apex/CCSMerlinOrderButtonController.getUserData';

import PROFILE  from '@salesforce/schema/User.Profile.Name';
import ROLE     from '@salesforce/schema/User.role__c';
import USER_ID  from '@salesforce/user/Id';


export default class CCSMerlinOrderButton extends LightningElement {

    @api recordId;

    error ;
    userData;
    opportunityData;


    @wire(getOpportunityData, { oppoId: '$recordId' })
    opportunityData;


    @wire(getUserData, {    }) 
    userData;


    handleClick(event) {
        getOpportunityData({ oppoId: this.opportunityData.data.Id })
            .then(() => {
                refreshApex(this.opportunityData)
                    .then(() => {
                        console.log('opportunityData', this.opportunityData.data);
                        console.log('this.userData.data.Profile.Name', this.userData.data.Profile.Name);
                        console.log('this.userData.data.role__c', this.userData.data.role__c);
                        console.log('this.opportunityData.data.CCS_GFN_number__c', this.opportunityData.data.CCS_GFN_number__c);
                            if(this.opportunityData.data.Type == 'New GFN' && !(this.opportunityData.data.CCS_GFN_number__c == '' || this.opportunityData.data.CCS_GFN_number__c == null)) {
                                alert("Pokud Typ obchodní příležitosti = New GFN, pole Zákaznické číslo GFN musí být prázdné.");
                            }
                            else if(this.opportunityData.data.Type == 'Existing GFN' && (this.opportunityData.data.CCS_GFN_number__c == '' || this.opportunityData.data.CCS_GFN_number__c == null) &&
                                                                                        (this.userData.data.role__c != 'Altevida Telesales Team Lead' && this.userData.data.role__c != 'Altevida CCS Telesales' && this.userData.data.role__c != 'Altevida Shell Telesales' &&
                                                                                        this.userData.data.Profile.Name != 'CCS API System Admin' && this.userData.data.Profile.Name != 'CCS System Administrator' && this.userData.data.Profile.Name != 'System Administrator') &&
                                                                                        (this.opportunityData.data.Product_Solicited__c == 'CCS Limit' || this.opportunityData.data.Product_Solicited__c == 'CCS Limit SK' || this.opportunityData.data.Product_Solicited__c == 'CCS Limit+' || this.opportunityData.data.Product_Solicited__c == 'CCS Limit+ SK' || this.opportunityData.data.Product_Solicited__c == 'CCS Limit+ mini' || this.opportunityData.data.Product_Solicited__c == 'CCS Limit M4' || this.opportunityData.data.Product_Solicited__c == 'CCS Limit PRIM' || this.opportunityData.data.Product_Solicited__c == 'CCS Limit NP' || this.opportunityData.data.Product_Solicited__c == 'CCS LIMIT Exclusive' || this.opportunityData.data.Product_Solicited__c == 'CCS Carnet' || this.opportunityData.data.Product_Solicited__c == 'CCS Carnet SK' || this.opportunityData.data.Product_Solicited__c == 'CCS Carnet Služba' || this.opportunityData.data.Product_Solicited__c == 'CCS Carnet Služba SK' || this.opportunityData.data.Product_Solicited__c == 'CCS Carnet OBD2' || this.opportunityData.data.Product_Solicited__c == 'CCS Carnet OBD2 SK' || this.opportunityData.data.Product_Solicited__c == 'CCS Carnet NP')) {
                                alert("Pokud Typ obchodní příležitosti = Existing GFN, je nutno vyplnit pole Zákaznické číslo GFN.");
                            }
                            else if(this.opportunityData.data.IsClosed == true) {
                                alert("Objednávku lze učinit pouze na otevřené Příležitosti. // You can create new Order only on open Opportunity.");
                            }
                            else if(this.opportunityData.data.Number_of_CCS_Order__c != '0' && this.opportunityData.data.Number_of_CCS_Order__c != '' && this.opportunityData.data.Number_of_CCS_Order__c != null) {
                                alert("Pod touto Příležitostí již CCS Order existuje, vytvořte prosím novou Příležitost.");
                            }
                            else{
                                window.open('https://' +this.opportunityData.data.Account.CCS_Merlin_Order_Button_Address__c + '.' +
                                this.opportunityData.data.Account.CCS_Merlin_Order_Button__c + '/login?OpportunityID=' + this.recordId + '&IC=' +
                                this.opportunityData.data.Account.CCS_Company_ID__c + '&ADM=' + this.opportunityData.data.CCS_Merlin_Order_Button__c + '&CHA=' + this.opportunityData.data.Sec_Channel__c + '&PRI=' + this.opportunityData.data.CCS_priobjednavka__c);
                            }
            });
        })
    }
}