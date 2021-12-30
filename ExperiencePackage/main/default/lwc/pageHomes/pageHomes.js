import { LightningElement, api } from 'lwc';
// import { allHomes } from 'data/javascript';

export default class PageHomes extends LightningElement {
    @api
    user;
    @api
    favoriteHomes;

    // Homes data... format prices to currencies.
    homes = [...allHomes];
}