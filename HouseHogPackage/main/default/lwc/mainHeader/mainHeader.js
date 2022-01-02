import { LightningElement, api, wire } from 'lwc';
import siteChannel from '@salesforce/messageChannel/siteChannel__c';
import {subscribe, publish, MessageContext} from 'lightning/messageService';

export default class MainHeader extends LightningElement {
    // CORE VARIABLES
    signedIn = false;
    currentPage = "splash";
    get showReturnToHome() {
        return (!this.isMainPage(this.currentPage));
    }

    // Lightning Message Service Controller
    @wire(MessageContext)
    context;
    connectedCallback() {
        this.subscription = subscribe(this.context, siteChannel, (message) => {
            this.messagePosted(message);
        });

        // Update page from cookie, if it exists
        console.log("HEADER connected callback");
        let cookiePage = this.getCookie("page");
        if (this.isMainPage(cookiePage)) {
            cookiePage = ""; // Defaults to splash page
        }
        this.setPage(cookiePage);
    }
    messagePosted(message) {
        this.signedIn = message.signedIn;
        //this.mainSection = message.mainSection;
        this.currentPage = message.currentPage;
    }
    postPage() {
        const data = { currentPage: this.currentPage };
        publish(this.context, siteChannel, data);
        console.log('HEADER Page posted to ' + this.currentPage);
    }

    // Cookie method for navigation
    // LMS clears all values when refreshing/switching pages
    setPage(to) {
        console.log("HEADER setting page TO: " + to + " FROM " + this.currentPage);
        if (!to) { to = "splash"; }; // Default to splash page

        this.setCookie("page", to);
        this.currentPage = to;
        this.postPage();
    }
    // connectedCallback() {
    //     this.setPage(this.getCookie('page'));
    // }
    
    // Navigation items
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
    returnHomeLinks = [
        { label:"Return to Main Page", page: "splash"},
    ];

    // On clicking a navigation item
    handleNavigation(event) {
        let targetPage = event.detail;
        if (targetPage === this.currentPage) { return; }
        console.log("navigating: " + targetPage);
        console.log("    from: " + this.currentPage);
        
        // Several SPA pages consolidated to one navigation link
        let fromMain = this.isMainPage(this.currentPage);
        let toMain = this.isMainPage(targetPage);

        this.setPage(targetPage);
        if (fromMain && toMain) { return; }

        let goHome = !fromMain && toMain;
        this.openTarget(goHome);
    }
    openTarget(toMain) {
        if (toMain) {
            window.open("../", "_self");
            console.log("NAV TO HOME");
            return;
        }
        if (this.currentPage == "signin") {
            window.open("login", "_self");
            console.log("NAV TO SIGNIN");
            return;
        }
        if (this.currentPage == "signup") {
            window.open("SelfRegister", "_self");
            console.log("NAV TO SIGNUP");
            return;
        }
    }

    // Consolidates SPA pages to one category
    isMainPage(target) {
        let result = true;
        switch (target) {
            case "signin":
            case "signup":
                result = false;
        }
        return result;
    }

    // From w3schools
    // Using cookies to track the page... LMS clears when changing pages (e.g. community login)
    getCookie(cookieKey) {
        let name = cookieKey + "=";
        let decodedCookie = decodeURIComponent(document.cookie);

        console.log(decodedCookie);

        let cookieContents = decodedCookie.split(';');
        for(let i = 0; i <cookieContents.length; i++) {
          let cookie = cookieContents[i];
          while (cookie.charAt(0) == ' ') {
            cookie = cookie.substring(1);
          }
          if (cookie.indexOf(name) == 0) {
            return cookie.substring(name.length, cookie.length);
          }
        }
        return "";
    }
    setCookie(cookieKey, toValue) {
        console.log("HEADER Setting cookie " + cookieKey + " TO " + toValue);
        const d = new Date();
        let expirationDays = 0;
        let expirationHours = 4;
        d.setTime(d.getTime() 
            + (expirationDays * 24 * 60 * 60 * 1000)
            + (expirationHours * 60 * 60 * 1000)
        );

        let expires = "expires="+d.toUTCString();
        document.cookie = cookieKey + "=" + toValue + ";" + expires + ";path=/";
      }
}