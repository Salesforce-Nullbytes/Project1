import {LightningElement} from 'lwc';

export default class newStudent extends LightningElement {

    handleStudentSubmit() {
        let listOfStudentInfo = this.template.querySelectorAll("input[type=text]");

        let newStudentName = listOfStudentInfo[0].value;
        let newParentName = listOfStudentInfo[1].value;
        let newParentEmail = listOfStudentInfo[2].value;
    }
}