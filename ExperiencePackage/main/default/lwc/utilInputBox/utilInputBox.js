import { LightningElement, api } from 'lwc';

export default class UtilInputBox extends LightningElement {
    // Simply give access to all for parent
    @api
    myName;
    @api
    myValue;
    // inline versus multiple lines (for iterators)
    @api
    inline = false;
    // Set to track change event on input
    @api
    trackChange = false;
    // Set input type to password
    @api
    password = false;

    get inputType() {
        return (this.password)? "password" : "text";
    }

    handleChange(event) {
        if (!this.trackChange) return;
        
        this.dispatchEvent(new CustomEvent('typing', {
            detail: event.target.value,
        }));
    }
}