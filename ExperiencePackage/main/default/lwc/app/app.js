import { LightningElement } from 'lwc';

export default class App extends LightningElement {
    // app state starting points...
    signedIn = false;
    signInPrompt = false;
    onPage = "splash";

    handleSignIn() {
        this.signedIn = true;
        this.onPage = "profile";
    }

    handleSignOut() {
        this.signedIn = false;
        this.onPage = "splash";
    }

    handleNav(event) {
        console.log("navigating: " + event.detail);
        switch(event.detail) {
            case "signin":
                this.signInPrompt = true;
                break;
            case "signout":
                this.handleSignOut();
                break;
            default:
                this.onPage = event.detail;
        }
    }

    handleBtn(event) {
        console.log("Button handler: " + event.detail);
        switch(event.detail) {
            case "closemodal":
                this.signInPrompt = false;
                break;
            case "login":
                this.signInPrompt = false;
                this.handleSignIn();
                break;
            default:
                console.log("Heard unrecognized button event...");
        }
    }
}