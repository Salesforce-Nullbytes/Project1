import { LightningElement, track, api, wire } from 'lwc';
import GetAccountFinancialData from "@salesforce/apex/ExperienceController.GetAccountFinancialData";
import UpdatePersonalDetails from "@salesforce/apex/ExperienceController.UpdatePersonalDetails";

export default class PageFinancing extends LightningElement {
    // User must be signed in to access financing features
    @api
    signedIn;

    // Core data
    //@wire(GetAccountFinancialData)
    // currentUser;
    // get uName() {
    //     return this.dataProperty(this.currentUser.data, "NotName");
    // }
    // get uAnnualIncome() {
    //     return this.dataProperty(this.currentUser.data, "Annual_Income__c");
    // }
    // get uMonthlyDebt() {
    //     return this.dataProperty(this.currentUser.data, "Monthly_Debt_Payments__c");
    // }
    // get uFICO() {
    //     return this.dataProperty(this.currentUser.data, "FICO__c");
    // }
    // get uBirthDate() {
    //     return this.dataProperty(this.currentUser.data, "Birth_Date__c");
    // }
    dataProperty(data, property) {
        if (!data || !data.hasOwnProperty(property)) { return null; }
        return data[property];
    }

    uName = '';
    @wire(GetAccountFinancialData)
    getUser({ error, data }) {
        if (error) {
            console.log("Error retrieving Account data...");
            return;
        }
        this.uName = this.dataProperty(data, "Name");
        let income = this.dataProperty(data, "Annual_Income__c");
        let debt = this.dataProperty(data, "Monthly_Debt_Payments__c");
        let fico = this.dataProperty(data, "FICO__c");
        let dob = this.dataProperty(data, "Birth_Date__c");
        this.personalDetails = this.makePersonalDetails(income, debt, fico, dob);
    }

    // Input fields for loan quote, initialized to blank.
    inputs = [
        { name: "Home Price", value: ""},
        { name: "Down Payment", value: ""},
        { name: "Term (Years)", value: ""},
        { name: "Loan Type", value: ""},
    ];

    // Initialize to user data, but allow changes to be posted.
    //@track
    personalDetails = [
        { name: "Annual Income", value: ""},
        { name: "Monthly Debt Payments", value: ""},
        { name: "FICO Credit Score", value: ""},
        { name: "Date of Birth", value: ""},
    ];

    makePersonalDetails(income, debt, fico, dob) {
        let array = [
            { name: "Annual Income", value: income},
            { name: "Monthly Debt Payments", value: debt},
            { name: "FICO Credit Score", value: fico},
            { name: "Date of Birth", value: dob},
        ];
        return array;
    }

    handleCalculateClick() {
        console.log("CALCULATING!");
    }

    handleUpdateClick() {
        console.log("UPDATING!");

        UpdatePersonalDetails({
            income: this.personalDetails[0].value,
            debt: this.personalDetails[1].value,
            fico: this.personalDetails[2].value,
            dob: this.personalDetails[3].value
        })
        .then((result) => {
            console.log("Have changes occurred? " + result);
        })
        .catch((error) => {
            console.log('Received an error: ' + JSON.stringify(error));
        });
    }

    // To capture changes on input forms
    handleFieldChange(event) {
        let sourceIndex = event.target.dataset.index;
        let value = event.detail;

        this.inputs[sourceIndex].value = value;
    }
    handleDetailsChange(event) {
        let sourceIndex = event.target.dataset.index;
        let value = event.detail;

        this.personalDetails[sourceIndex].value = value;
    }

    get greeting() {
        let name = "House Hunter";
        if (this.uName) { name = this.uName; }
        let greeting = `Hi, ${name}!`;
        return greeting;
    }
    get hasFinancingDetails() {
        let result = true;
        
        if (!this.uAnnualIncome) { result = false; }
        if (!this.uMonthlyDebt) { result = false; }
        if (!this.uFICO) { result = false; }
        if (!this.uBirthDate) { result = false; }
        
        return result;
    }
}