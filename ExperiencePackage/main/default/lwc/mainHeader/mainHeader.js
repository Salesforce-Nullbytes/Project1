import { LightningElement, api } from 'lwc';

export default class MainHeader extends LightningElement {
    @api
    signedIn;
    @api
    currentPage;

    navLinks = [
        { label:"Homes", page: "homes"},
        { label:"Realtors", page: "realtors"},
        { label:"Financing", page: "financing"},
    ];
    signedOutLinks = [
        { label:"Sign In", page: "signin", logs: "in"},
        { label:"Sign Up", page: "signup"},
    ];
    signedInLinks = [
        { label:"Profile", page: "profile"},
        { label:"Sign Out", page: "signout", logs: "out"},
    ];
}