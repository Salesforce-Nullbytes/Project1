import {LightningElement} from 'lwc';

export default class signUp extends LightningElement {
    showNewTeacher = false;
    showNewStudent = false;
    
    clickTeacherSignup() {
        this.showNewTeacher = !this.showNewTeacher;
        this.showNewStudent = false;
    }

    clickStudentSignup() {
        this.showNewStudent = !this.showNewStudent;
        this.showNewTeacher = false;
    }
    
}