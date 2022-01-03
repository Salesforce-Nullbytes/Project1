import {LightningElement} from 'lwc';
import insertNewTeacher from '@salesforce/apex/TeacherController.insertNewTeacher';

export default class newTeacher extends LightningElement {

    handleTeacherSubmit() {
        let listOfTeacherInfo = this.template.querySelectorAll("input[type=text]");

        let newTeacherName = listOfTeacherInfo[0].value;
        let newTeacherEmail = listOfTeacherInfo[1].value;

        insertNewTeacher({teacherName : newTeacherName, teacherEmail : newTeacherEmail})
            .then((result) => {
               alert("Signup Successful!");
            })
            .catch((error) => {
                alert("Signup Unsuccessful!");
            });

        document.getElementsByClassName("teacherName").reset();
    }
}