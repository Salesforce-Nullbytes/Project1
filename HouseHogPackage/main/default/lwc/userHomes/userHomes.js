import { LightningElement, api } from 'lwc';

export default class UserHomes extends LightningElement {
    // User always signed in on profile page
    @api
    favoriteHomes;
}