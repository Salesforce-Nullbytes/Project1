import { LightningElement, api } from 'lwc';

export default class UtilCard extends LightningElement {
    
    // Main card image
    // OBJECT => {link:"...",alt="..."}
    @api
    image;
    @api
    status;
}