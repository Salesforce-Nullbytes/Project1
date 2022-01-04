import { LightningElement, track, api, wire } from 'lwc';
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
    get showSplash() {
        return this.currentPage === "splash";
    }

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
}