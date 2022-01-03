import {LightningElement} from 'lwc';
import insertNewStudent from '@salesforce/apex/StudentController.insertNewStudent';

export default class newStudent extends LightningElement {

    handleStudentSubmit() {
        let listOfStudentInfo = this.template.querySelectorAll("input[type=text]");

        let newStudentName = listOfStudentInfo[0].value;
        let newParentName = listOfStudentInfo[1].value;
        let newParentEmail = listOfStudentInfo[2].value;


        insertNewStudent({studentName : newStudentName, parentName : newParentName, parentEmail : newParentEmail})
            .then((result) => {
                alert("Signup Successful!");
            })
            .catch((error) => {
                alert("Signup Unsuccessful!");
        });

        document.getElementsByClassName("studentName").reset();
    }
}