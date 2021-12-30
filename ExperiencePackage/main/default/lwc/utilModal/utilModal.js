import { LightningElement, api } from 'lwc';

export default class UtilModal extends LightningElement {
    
    // modal params...
    @api
    show;

    @api
    myLabel;

    get cssClass() {
        return (this.show)? "modal show" : "modal hide";
    }
}