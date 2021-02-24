import { LightningElement, api } from 'lwc';

export default class ModalBox extends LightningElement {
    @api confirmButtonLabel;
    @api cancelButtonLabel;
    @api popupMessage;
    @api popupTitle;
    @api callbackFunction;
    @api wishToContMessage;
    @api thisArg;
    @api supplierRec;
    @api account;
    supplierRec;

    connectedCallback() {
        this.wishToContMessage = (typeof this.wishToContMessage !== undefined) ? this.wishToContMessage : 'Wish';
    }

    handleCancel(){
        this.thisArg.showAndHideModal = false;
    }
}