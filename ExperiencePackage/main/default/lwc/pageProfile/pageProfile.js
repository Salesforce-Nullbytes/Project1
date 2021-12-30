import { LightningElement, api } from 'lwc';

export default class PageProfile extends LightningElement {
    // User always signed in on profile page
    @api
    user;
    @api
    favoriteHomes;
    @api
    userRealtor;

    profilePic = "./resources/photos/defaultprofilepic.jpg";

    get greeting() {
        let name = "Shopper";
        if (this.user) {
            if (this.user.name) name = this.user.name;
            else if (this.user.username) name = this.user.username;
        }
        let greeting = `Hi, ${name}!`;
        return greeting;
    }

    get details() {
        let details = [];
        details.push({ key: "Full Name",
            value: this.user.name || "(Not known)"
        });
        details.push({ key: "Username",
            value: this.user.username || "(Could not find username)" 
        });
        details.push({ key: "Email address",
            value: this.user.email || "(Could not find Email address)" 
        });
        details.push({ key: "Annual Income",
            value: this.user.phone || "(Not known)" 
        });
        details.push({ key: "Monthly Debt Payments",
            value: this.user.phone || "(Not known)" 
        });
        details.push({ key: "FICO Credit Score",
            value: this.user.phone || "(Not known)" 
        });
        details.push({ key: "Date of Birth",
            value: this.user.phone || "(Not known)" 
        });

        return details;
    }
}