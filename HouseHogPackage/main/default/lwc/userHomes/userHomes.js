import { LightningElement, api } from 'lwc';
import defaultHome from '@salesforce/resourceUrl/defaultHome';

export default class UserHomes extends LightningElement {
    @api
    prospectList;

    defaultImage = {
        link: defaultHome,
        alt: "default home image"
    };
}