import { LightningElement, api, wire, track } from 'lwc';
import defaultHome from '@salesforce/resourceUrl/defaultHome';
import UserProspects from "@salesforce/apex/ExperienceController.UserProspects";
import AllListedProperties from "@salesforce/apex/ExperienceController.AllListedProperties";

export default class PageHomes extends LightningElement {
    @api
    signedIn;

    @wire(UserProspects)
    userProspects;
    get hasProspects() {
        if (!this.allProspects) { return false; }
        if (!this.allProspects.data) { return false; }
        return true;
    }
    @wire(AllListedProperties)
    allProperties;
    get hasProperties() {
        if (!this.allProperties.data) { return false; }
        return true;
    }

    defaultImage = {
        link: defaultHome,
        alt: "default home image"
    };
}