import {LightningElement} from 'lwc';

export default class meetOurTeachers extends LightningElement {
showSeeMore = true;
showMoreTeachers = false;

createMoreTeachers() {
    this.showSeeMore = !this.showSeeMore;
    this.showMoreTeachers = !this.showMoreTeachers;
}

createLessTeachers() {
    this.showSeeMore = !this.showSeeMore;
    this.showMoreTeachers = !this.showMoreTeachers;
}

}