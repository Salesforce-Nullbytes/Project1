import {LightningElement} from 'lwc';
import teacher1 from '@salesforce/resourceUrl/teacher1';
import teacher2 from '@salesforce/resourceUrl/teacher2';
import teacher3 from '@salesforce/resourceUrl/teacher3';

export default class teachers extends LightningElement {
    teacher1 = teacher1;
    teacher2 = teacher2;
    teacher3 = teacher3;

    showTeachers = true;

    myTeachers = [
        { name: "William Bermudez", image: teacher1 },
        { name: "Suzanna Gianattasio", image: teacher2 },
        { name: "Antonia Shachar", image: teacher3 }
    ];

}