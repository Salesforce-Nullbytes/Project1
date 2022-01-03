import { LightningElement } from 'lwc';
import JimmyH from '@salesforce/resourceUrl/JimmyH';
import PinkFloyd from '@salesforce/resourceUrl/PinkFloyd';
export default class events extends LightningElement {
    JimmyH = JimmyH;
    PinkFloyd =PinkFloyd;
    show = true;

    hide() {
        this.show = !this.show;
    }
}
