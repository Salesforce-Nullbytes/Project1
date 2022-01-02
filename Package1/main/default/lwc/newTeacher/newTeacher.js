import {LightningElement} from 'lwc';

export default class newTeacher extends LightningElement {

    handleTeacherSubmit() {
        let listOfTeacherInfo = this.template.querySelectorAll("input[type=text]");

        let newTeacherName = listOfTeacherInfo[0].value;
        let newTeacherEmail = listOfTeacherInfo[1].value;

        console.log(newTeacherName);
        console.log(newTeacherEmail);
    }

}