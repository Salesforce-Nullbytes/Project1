import { LightningElement, api } from 'lwc';
import splash from '@salesforce/resourceUrl/splash';

export default class PageSplash extends LightningElement {
    // True will render the sign-up page
    @api
    signup = false;
    // Input fields for signup page, if needed.
    inputs = [
        { name: "Email", value: ""},
        { name: "Username", value: ""},
        { name: "Password", value: ""},
    ];

    splashImage = splash;

    handleRegisterClick() {
        // Send event up to c-content (who holds main data)
        // c-content will then send simple message to app for signin
        this.dispatchEvent(new CustomEvent('register', {
            detail: {
                email: this.inputs[0].value,
                username: this.inputs[1].value,
                password: this.inputs[2].value,
            },
        }));
    }
    // To capture changes on input form
    handleFieldChange(event) {
        let sourceIndex = event.target.dataset.index;
        let value = event.detail;

        this.inputs[sourceIndex].value = value;
    }
}