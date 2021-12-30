import { LightningElement, api } from 'lwc';

export default class UserRealtor extends LightningElement {
    // User always signed in on profile page
    @api
    userRealtor;

    get realtorInfo() {
        let info = [];
        info.push({ key: "Realtor Name",
            value: this.userRealtor.name || "(Name not available)"
        });
        info.push({ key: "Agency",
            value: this.userRealtor.agency || "(Could not find agency)" 
        });
        info.push({ key: "email address",
            value: this.userRealtor.email || "(Email not provided)" 
        });
        info.push({ key: "Phone #",
            value: this.userRealtor.phone || "(Phone # not provided)" 
        });

        return info;
    }
}