import {LightningElement} from 'lwc';

export default class freeTrialLesson extends LightningElement {

    showButton = false;

    mouseOver() {
        this.showButton = true;
    }

    mouseOut() {
       this.showButton = false;
    }
}