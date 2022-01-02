import { LightningElement, track, api, wire } from 'lwc';
import GetUser from "@salesforce/apex/ExperienceController.GetUser";
import UserId from "@salesforce/apex/ExperienceController.UserId";
import siteChannel from '@salesforce/messageChannel/siteChannel__c';
import {subscribe, MessageContext} from 'lightning/messageService';

// NOTE: importing allUsers for Demo purposes only (no back end available).
// import { allHomes, allRealtors, allUsers } from 'data/javascript';

export default class MainContent extends LightningElement {
    // CORE VARIABLES
    currentPage = "splash";
    signedIn = false;

    get testMsg() {
        return this.signedIn ? "Signed In" : "Not Signed In";
    }

    @wire(UserId)
    ValidateSignIn({ error, data }) {
        if (data) { this.signedIn = true; }
        else if (error) { this.signedIn = false; }
    }

    // Core data
    @wire(GetUser)
    currentUser;
    get uName() {
        return this.currentUser.data.Name;
    }
    get uContactId() {
        return this.currentUser.data.ContactId;
    }
    get uAccountId() {
        return this.currentUser.data.AccountId;
    }
    get uEmail() {
        return this.currentUser.data.Email;
    }

    // Lightning Message Service Controller
    @wire(MessageContext)
    context;
    connectedCallback() {
        this.subscription = subscribe(this.context, siteChannel, (message) => {
            this.messagePosted(message);
        });
    }
    messagePosted(message) {
        this.currentPage = message.currentPage;
    }

    promptUsername = "hoghouse";
    promptPassword = "pigpen";

    // // NORMALLY SHOULDN'T DO THIS (Demo purposes only)
    // @track
    // usersFull = [...allUsers];

    // REPLACED BY NEW PAGE IN LWR
    //@api
    //signInPrompt;
    @api
    get userSignedIn() {
        return this.signedIn;
    }
    set userSignedIn(to) {
        if (this.signedIn && !to) {
            this.user = null;
            this.favoriteHomes = null;
            this.userRealtor = null;
        }
        this.signedIn = to;
    }

    @track
    user = null;
    @track
    favoriteHomes = null;
    @track
    userRealtor = null;

    // Main navigation items
    get showHomes() {
        return this.currentPage === "homes";
    }
    get showRealtors() {
        return this.currentPage === "realtors";
    }
    get showFinancing() {
        return this.currentPage === "financing";
    }
    get showProfile() {
        return this.currentPage === "profile";
    }

    // Splash and signup subpage
    get showSplash() {
        //return this.currentPage === "splash" || this.signUp;
        return this.currentPage === "splash";
    }
    // get signUp() {
    //     return this.currentPage === "signup";
    // }

    // // For the modal to appear on top of page...
    handleCloseModal() {
        // HANDLED BY APP COMPONENT
    }

    handleBtn(event) {
        if (event.detail != "login") return;

        // Must compare user to data set & retrieve full details
        this.getUser(this.promptUsername, this.promptPassword);
        this.dispatchEvent(new CustomEvent('signin'));
    }

    handleRegister(event) {
        let params = event.detail;
        // Would normally send data to server
        for (let user of this.usersFull) {
            if (user.username === params.username) {
                alert("Username is already taken!");
                return;
            }
        }
        this.usersFull.push(params);
        alert("Registration was successful!");
        this.user = params;
        this.dispatchEvent(new CustomEvent('signin'));
    }

    // // NOTE: this should be handled on back-end server
    // getUser(username, password) {
    //     for (let user of this.usersFull) {
    //         if (user.username === username & user.password === password) {
    //             this.user = user;
    //             this.favoriteHomes = allHomes.filter(home => this.user.favoriteIDs.includes(home.ID));
    //             this.userRealtor = allRealtors.find( obj => obj.ID === this.user.realtorID);
    //             return;
    //         }
    //     }
    // }

    // // From w3schools
    // // Using cookies to track the page... LMS clears when changing pages (e.g. community login)
    // getCookie(cookieKey) {
    //     let name = cookieKey + "=";
    //     let decodedCookie = decodeURIComponent(document.cookie);
    //     let cookieContents = decodedCookie.split(';');
    //     for(let i = 0; i <cookieContents.length; i++) {
    //       let cookie = cookieContents[i];
    //       while (cookie.charAt(0) == ' ') {
    //         cookie = cookie.substring(1);
    //       }
    //       if (cookie.indexOf(name) == 0) {
    //         return cookie.substring(name.length, cookie.length);
    //       }
    //     }
    //     return "";
    // }
}