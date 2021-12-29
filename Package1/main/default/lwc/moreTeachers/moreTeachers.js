import {LightningElement} from 'lwc';
import teacher4 from '@salesforce/resourceUrl/teacher4';
import teacher5 from '@salesforce/resourceUrl/teacher5';
import teacher6 from '@salesforce/resourceUrl/teacher6';
import teacher7 from '@salesforce/resourceUrl/teacher7';
import teacher8 from '@salesforce/resourceUrl/teacher8';
import teacher9 from '@salesforce/resourceUrl/teacher9';

export default class moreTeachers extends LightningElement {
    teacher4 = teacher4;
    teacher5 = teacher5;
    teacher6 = teacher6;
    teacher7 = teacher7;
    teacher8 = teacher8;
    teacher9 = teacher9;

    showTeachers = true;

    myTeachers = [
        { name: "Elsie Foley", image: teacher4 },
        { name: "Jaime Kendall", image: teacher5 },
        { name: "Margie Lowe", image: teacher6 },
        { name: "Ewan Phillips", image: teacher7 },
        { name: "Marrisa Burton", image: teacher8 },
        { name: "Britany O'Doherty", image: teacher9 }
    ];

}