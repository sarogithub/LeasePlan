import { LightningElement, api } from 'lwc';

export default class SupplierMap extends LightningElement {
    @api supplierRec;
    @api recordId;
    @api objectApiName = 'Supplier__c';
    @api account;

    centerLoc;
    mapMarkers = [];
    markersTitle = "Supplier List";
    
    connectedCallback(){
        if(this.supplierRec){
            console.log('JSON --> '+ JSON.stringify(this.supplierRec));
            let supplier = this.supplierRec;
            this.recordId = supplier.Id;
            let accountDetail = this.account;

            this.mapMarkers = [
                {
                    value: accountDetail.Name,
                    location: {
                        City: accountDetail.BillingCity,
                        Country: accountDetail.BillingCountry,
                        PostalCode: accountDetail.BillingPostalCode,
                        State: accountDetail.BillingState,
                        Street: accountDetail.BillingStreet
                    },
                    icon: 'standard:omni_supervisor',
                    title: accountDetail.Name + ' (Customer)',
                    description : accountDetail.BillingAddress__c,
                    mapIcon: {
                        path: 'M 125,5 155,90 245,90 175,145 200,230 125,180 50,230 75,145 5,90 95,90 z',            
                        fillColor: 'blue',
                        fillOpacity: .8,
                        strokeWeight: 0,
                        scale: .10
                    }
                },
                {
                    value: supplier.Name,
                    location: {
                        City: supplier.City__c,
                        Country: supplier.Country__c,
                        PostalCode: supplier.PostalCode__c,
                        State: supplier.State__c,
                        Street: supplier.Street__c
                    },
                    icon: 'standard:omni_supervisor',
                    title: supplier.Name + ' (Supplier)',
                    description : supplier.Address__c
                }
            ];      
        }
    }

    handleMarkerSelect(event) {
        this.selectedMarkerValue = event.target.selectedMarkerValue;
    }
}