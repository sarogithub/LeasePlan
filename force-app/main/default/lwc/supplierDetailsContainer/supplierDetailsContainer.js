import { LightningElement, track, api, wire } from 'lwc';  
import fetchSupplier from '@salesforce/apex/SupplierController.fetchSupplier';  
import noDataAvailable from '@salesforce/label/c.noDataAvailableInSupplierObject';
import supplierFilteredBasedOnBillingCity from '@salesforce/label/c.supplierFilteredBasedOnBillingCity';


export default class SupplierDetailsContainer extends LightningElement {
    supplierList;  
    error;  
    columns = [];  
    searchKey = '';
    account;
    isLoading;
    infoMessage;

    @api recordId;
    @api billingCity;

    @api label = {
        noDataAvailable : noDataAvailable,
        supplierFilteredBasedOnBillingCity : supplierFilteredBasedOnBillingCity
    }

    connectedCallback(){
        this.fetchSupp(this.searchKey);
    }
    
    fetchSupp(searchKey){
        this.isLoading = true;
        fetchSupplier(
            {
                inputArg: JSON.stringify({
                    recordId : this.recordId,
                    searchKey: searchKey
                })
            }
        )
        .then(result => {  
            let resultObj = JSON.parse(result);
            let fieldNameArray = [];
            let col = [];
            let fieldNameFromFieldSet = [];
            
            const actions = [
                { label: 'Map', name: 'map' }
            ];

            const rowButtons = [
                { type: 'action', typeAttributes: { 
                    rowActions: actions
                }}
            ];
            
            if(resultObj.account){
                this.account = resultObj.account; 
                this.billingCity = resultObj.account.BillingCity;
            }

            if(resultObj.supplierObjFieldSetFields){
                resultObj.supplierObjFieldSetFields.forEach((supplierFieldName) => {
                    fieldNameFromFieldSet.push(supplierFieldName);
                });
            }

            if(resultObj.supplierList.length > 0){
                resultObj.supplierList.forEach((supplier) => {
                    let obj;
                    Object.keys(supplier).forEach((fieldName) => {
                        if(!fieldNameArray.includes(fieldName)){
                            if(fieldNameFromFieldSet.includes(fieldName)){
                                let fieldLabel = resultObj.supplierObjFieldApiToLabelMap[fieldName];
                                if(resultObj.supplierObjFieldApiToLabelMap.hasOwnProperty(fieldName)){
                                    obj = { label: fieldLabel, fieldName: fieldName }
                                    fieldNameArray.push(fieldName);  
                                    col.push(obj);
                                }
                            }
                        }
                    })
                });

                this.columns = rowButtons.concat(col); 
                this.supplierList = resultObj.supplierList;
            }else{
                this.infoMessage = this.label.noDataAvailable + ' ' + this.billingCity;
            }
            this.isLoading = false;
        })  
        .catch(error => {  
            this.error = error;  
        });
    }

    handleKeyChange(event){  
        const searchKey = event.target.value;  
        this.fetchSupp(searchKey); 
    }
}
