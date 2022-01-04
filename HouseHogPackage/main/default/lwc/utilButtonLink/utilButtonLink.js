import { LightningElement, api } from 'lwc';

export default class UtilButtonLink extends LightningElement {
    @api
    myLabel;

    // Boolean attribute--set true if HTML markup is link
    //   if false, HTML markup is button (for accessibility)
    @api
    anchor;

    // event detail to trigger & 'active-on' to set as active
    @api
    eventKey;

    // if key defined, this sets state to compare to for highlighting
    @api
    activeOn;

    get computeClass() {
        if (!this.eventKey) return "inactive";
        return (this.activeOn === this.eventKey) ? "active" : "inactive";
    }

    // if key defined, fire event with key as detail
    triggerEvent() {
        if (!this.eventKey) return;
        let eventName = (this.anchor) ? "nav" : "btn";
        return this.dispatchEvent(new CustomEvent(eventName, {
            detail: this.eventKey,
            bubbles: true,
            //composed: true // Must bubble all the way up
        }));
    }
}