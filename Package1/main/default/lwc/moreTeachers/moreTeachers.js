import {LightningElement} from 'lwc';

export default class moreTeachers extends LightningElement {

    showTeachers = true;

    myTeachers = [
        { name: "Elsie Foley", image: "../../../resources/teacher4.png" },
        { name: "Jaime Kendall", image: "../../../resources/teacher5.png" },
        { name: "Margie Lowe", image: "../../../resources/teacher6.png"},
        { name: "Ewan Phillips", image: "../../../resources/teacher7.png" },
        { name: "Marrisa Burton", image: "../../../resources/teacher8.png" },
        { name: "Britany O'Doherty", image: "../../../resources/teacher9.png"}
    ];

}