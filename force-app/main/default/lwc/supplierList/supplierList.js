import { LightningElement, api } from 'lwc';  

export default class SupplierList extends LightningElement {
    @api supplierList;
    @api columns;
    @api hideCheckboxColumn;
    @api showRowNoColumn;
    @api error;
    @api showAndHideModal = false;
    @api selectedSupplierRec;
    @api account;
    modalTitle = 'Supplier Details and Location';
    thisArg;  

    connectedCallback(){
        this.thisArg = this;
    }

    callRowAction(event){  
        const recId =  event.detail.row.Id;  
        const actionName = event.detail.action.name;  

        if(actionName === 'map'){ 
            this.selectedSupplierRec = event.detail.row;
            console.log('event.detail.row --> '+ JSON.stringify(event.detail.row));
            this.showAndHideModal = true;
        }         
    }  
}