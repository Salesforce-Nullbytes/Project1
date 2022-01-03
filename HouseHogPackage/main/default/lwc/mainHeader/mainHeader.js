import { LightningElement, wire } from 'lwc';
import UserId from "@salesforce/apex/ExperienceController.UserId";
import siteChannel from '@salesforce/messageChannel/siteChannel__c';
import {subscribe, publish, MessageContext} from 'lightning/messageService';
import getLogoutUrl from '@salesforce/apex/applauncher.IdentityHeaderController.getLogoutUrl';
import isGuest from "@salesforce/user/isGuest";

export default class MainHeader extends LightningElement {
    // CORE VARIABLES
    currentPage = "splash";
    signedIn = !isGuest;

    // @wire(UserId)
    // ValidateSignIn({ error, data }) {
    //     if (data) { this.signedIn = true; }
    //     else if (error) { this.signedIn = false; }
    // }

    // Lightning Message Service Controller
    @wire(MessageContext)
    context;
    connectedCallback() {
        this.subscription = subscribe(this.context, siteChannel, (message) => {
            this.messagePosted(message);
        });

        // Update page from cookie, if it exists
        let cookiePage = this.getCookie("page");
        if (this.isMainPage(cookiePage)) {
            cookiePage = ""; // Defaults to splash page
        }
        this.setPage(cookiePage);
    }
    messagePosted(message) {
        this.currentPage = message.currentPage;
    }
    postPage() {
        const data = { currentPage: this.currentPage };
        publish(this.context, siteChannel, data);
    }

    // Cookie method for navigation
    // LMS clears all values when refreshing/switching pages
    setPage(to) {
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
    returnHomeLinks = [
        { label:"Return to Main Page", page: "splash"},
    ];
    signedOutLinks = [
        { label:"Sign In", page: "signin", logs: "in"},
        { label:"Sign Up", page: "signup"},
    ];
    signedInLinks = [
        { label:"Profile", page: "profile"},
        { label:"Sign Out", page: "signout", logs: "out"},
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
            return;
        }
        if (this.currentPage == "signin") {
            window.open("login", "_self");
            return;
        }
        if (this.currentPage == "signup") {
            window.open("SelfRegister", "_self");
            return;
        }
        if (this.currentPage == "signout") {
            this.setPage("signin"); // No signout page... reset to Sign In
            console.log("signing out....");
            window.open(getLogoutUrl, "_self");
            return;
        }
    }

    // Consolidates SPA pages to one category
    isMainPage(target) {
        let result = true;
        switch (target) {
            case "signin":
            case "signup":
            case "signout":
                result = false;
        }
        return result;
    }
    // Lets site know to display the 'Return to Main Page' button
    get showReturnToHome() {
        return (!this.isMainPage(this.currentPage));
    }

    // From w3schools
    // Using cookies to track the page... LMS clears when changing pages (e.g. community login)
    getCookie(cookieKey) {
        let name = cookieKey + "=";
        let decodedCookie = decodeURIComponent(document.cookie);
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