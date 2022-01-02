import { LightningElement, api } from 'lwc';
// import { allRealtors } from 'data/javascript';

export default class PageRealtors extends LightningElement {
    @api
    user;
    @api
    userRealtor;

    // Homes data... format prices to currencies.
    realtors = [...allRealtors];
}