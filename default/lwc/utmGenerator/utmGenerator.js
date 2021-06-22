import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import getActiveForEteProduct from "@salesforce/apex/ETEGeneratorUtmUrl.getActiveForEteProduct";
import generateLink from "@salesforce/apex/ETEGeneratorUtmUrl.generateLink";
import Product2 from "@salesforce/schema/Product2";
import PRODUCT_FAMILY_FIELD from "@salesforce/schema/Product2.Family";

export default class UtmGenerator extends LightningElement {

    @track link;
    @track isReady;
    @track countries;
    @track notSelected = [];
    @track product2RecordType;
    
    @track selectedProducts = [];
    @track countryNamespaces = [];
    @track currentNamespace;
    @track currentCountryValue;
    @track selectedFamilyItems = [];

    totalValues = [];

    set currentCountry(value){
        this.currentCountryValue = value;
        this.countryNamespaces = value.namespaces.map(space => {
            return {
                label:space,
                value:space
            };
        });
        this.currentNamespace = value.namespaces[0];
    };

    get currentCountry(){
        return this.currentCountryValue.value;
    }

    @wire(getObjectInfo,{objectApiName:Product2})
    getObjectData({data,error}){
        if(data && data.defaultRecordTypeId){
            this.product2RecordType = data.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$product2RecordType",
        fieldApiName: PRODUCT_FAMILY_FIELD
    })
    product2PicklistValues({data,error}){
        if(data){
            this.totalValues = data.values;
            this.notSelected = [...this.totalValues];
            this.selectedFamilyItems = [];
        }
    }


    @wire(getActiveForEteProduct) 
    getActiveForEteProductWire({data, error}){
        if(data){
            this.countries = [];
            this._products = data;

            const countries = this._products.map(product => {
                const parseCountry = product.Country__c.split('-');
                const result = {
                    label: parseCountry[0],
                    value: parseCountry[0],
                    namespaces:[]
                };
                
                if(parseCountry[1]){
                    result.namespaces.push(parseCountry[1]);
                }
                return result;
            });

            countries.forEach(country => {
                const countryFound = this.countries.find(item => item.value === country.value );
                if(!countryFound){
                    this.countries.push(country);
                }else {
                    countryFound.namespaces = [...new Set([...countryFound.namespaces, ...country.namespaces])];
                }
            });

            this.currentCountry = this.countries[0];
            this.isReady = true;
        }
    }

    get products() {
        let result = this._products
            .filter(pr => pr.Country__c.split('-')[0] === this.currentCountry)
            .filter(pr => this.selectedFamilyItems.find(family => family.value === pr.Family))
            .map(pr=> {
                return { 
                    label: pr.Name, 
                    value: pr.Integration_Name__c 
                };
            });
        return result;
    }

    handleChangeCountry(event) {
        this.currentCountry = this.countries.find(country => country.value === event.detail.value);
        this.selectedProducts = [];
    }

    handleChangeProducts(event) {
        this.selectedProducts = event.detail.value;
        this.link = null;
    }

    handleChangeNamespaces(event) {
        this.currentNamespace = event.detail.value;
    }

    copyToClipboard(){
        const elHidden = document.createElement('textarea');
        elHidden.value = this.link;
        const tempWrapper = this.template.querySelector('.temp-text-area');
        tempWrapper.appendChild(elHidden);
        elHidden.select();
        document.execCommand('copy');
        tempWrapper.removeChild(elHidden);
    }

    renderedCallback(){
        if(this.selectedProducts.length && !this.isReady){
            this.template.querySelector('c-loading-content').text = 'Generating...';
        }
    }

    handleItemRemove (event) {
        const name = event.detail.item.name;
        const index = event.detail.index;
        const item = this.selectedFamilyItems.splice(index, 1);
        this.notSelected = [...this.notSelected,...item];
        this.selectedFamilyItems = [...this.selectedFamilyItems];
        this.selectedProducts = [];
    }

    handleChangeNotSelectedFamily (event) {
        const item = this.notSelected.find(it => it.value === event.detail.value);
        const index = this.notSelected.indexOf(item);
        this.notSelected.splice(index, 1);
        this.notSelected = [...this.notSelected];
        this.selectedFamilyItems.push(item);
        this.selectedProducts = [];
        this.template.querySelector('.utm-family').value = null;
    }

    async handleClickGenerate(){
        this.isReady = false;
        const data = {
            productsIntNames:this.selectedProducts.join(';'),
            country: this.getCountryWithNamespace(),
            implKey: this.getImplKey()
        };
        this.link = await generateLink(data);
        this.isReady = true;
    }

    getCountryWithNamespace(){
        let result = this.currentCountryValue.value;
        if(this.currentNamespace){
            result = `${result}-${this.currentNamespace}`;
        }
        return result;
    }

    getImplKey(){
        let result = this.getCountryWithNamespace();
        const isLotos = this.selectedFamilyItems.find(item => item.value === 'Lotos');
        if(result === 'Poland' && isLotos){
            result = 'Poland Lotos';
        }
        return result;
    }
}