import { LightningElement, api, wire } from 'lwc';
import GetUserFinancial from "@salesforce/apex/ExperienceController.GetUserFinancial";

export default class PageFinancing extends LightningElement {
    // User must be signed in to access financing features
    @api
    signedIn;

    // Core data
    @wire(GetUserFinancial)
    currentUser;

    // Input fields for signup page, if needed.
    inputs = [
        { name: "Home Price", value: ""},
        { name: "Down Payment", value: ""},
        { name: "Term (Years)", value: ""},
        { name: "Loan Type", value: ""},
    ];

    personalDetails = [
        { name: "Annual Income", value: ""},
        { name: "Monthly Debt Payments", value: ""},
        { name: "FICO Credit Score", value: ""},
        { name: "Date of Birth", value: ""},
    ];

    handleCalculateClick() {
        // // Send event up to c-content (who holds main data)
        // // c-content will then send simple message to app for signin
        // this.dispatchEvent(new CustomEvent('signin', {
        //     detail: {
        //         email: this.inputs[0].value,
        //         username: this.inputs[1].value,
        //         password: this.inputs[2].value,
        //     },
        // }));
        console.log("CALCULATING!");
    }

    // To capture changes on input forms
    handleFieldChange(event) {
        let sourceIndex = event.target.dataset.index;
        let value = event.detail;

        console.log("  INPUTS: " + sourceIndex + ", " + value);
        this.inputs[sourceIndex].value = value;
    }
    handleDetailsChange(event) {
        let sourceIndex = event.target.dataset.index;
        let value = event.detail;

        console.log("  DETAILS: " + sourceIndex + ", " + value);
        this.personalDetails[sourceIndex].value = value;
    }

    get greeting() {
        let name = "Customer";
        if (this.currentUser.data) {
            if (this.currentUser.data.name) {
                name = this.currentUser.data.name;    
            }
        }
        let greeting = `Hi, ${name}!`;
        return greeting;
    }
    get hasFinancingDetails() {
        let result = false;
        let user = this.currentUser.data;
        if (user) {
            // if (!this.user.annualIncome) result = false;
            // if (!this.user.monthlyDebtPayments) result = false;
            // if (!this.user.ficoScore) result = false;
            // if (!this.user.birthDate) result = false;  
            //result = true;
        }
        
        return result;
    }
}