import { LightningElement, api } from 'lwc';

export default class UtilContentBox extends LightningElement {
    
    // Text to display at top
    @api
    myHeading;
    
    // Renders as input form
    @api
    input = false;

    // Renders heading inline & thin padding
    @api
    thin = false;

    // Renders border radius 8px
    @api
    round = false;

    get myClass() {
        let result = "box";
        if (this.input) result += " input";
        if (this.thin) result += " thin";
        if (this.round) result += " round";
        return result;
    }
}