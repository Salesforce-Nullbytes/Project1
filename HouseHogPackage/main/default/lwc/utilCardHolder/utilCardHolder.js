import { LightningElement, api } from 'lwc';

export default class UtilCardHolder extends LightningElement {
    
    // Text to display at top
    @api
    myHeading;

    // Renders border radius 8px
    @api
    round = false;

    get myClass() {
        let result = "info";
        if (this.round) result += " round";
        return result;
    }
}