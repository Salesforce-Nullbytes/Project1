import { LightningElement, track, api } from 'lwc';

// NOTE: importing allUsers for Demo purposes only (no back end available).
// import { allHomes, allRealtors, allUsers } from 'data/javascript';

export default class MainContent extends LightningElement {
    signedIn = false;
    promptUsername = "hoghouse";
    promptPassword = "pigpen";

    // // NORMALLY SHOULDN'T DO THIS (Demo purposes only)
    // @track
    // usersFull = [...allUsers];

    @api
    currentPage = "splash"; // default
    @api
    signInPrompt;
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
        return this.currentPage === "splash" || this.signUp;
    }
    get signUp() {
        return this.currentPage === "signup";
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
}