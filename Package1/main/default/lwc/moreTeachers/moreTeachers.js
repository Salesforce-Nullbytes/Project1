import {LightningElement} from 'lwc';

export default class moreTeachers extends LightningElement {

    showTeachers = true;

    myTeachers = [
        { name: "Elsie Foley", image: "../../../../../images/teacher4.png" },
        { name: "Jaime Kendall", image: "../../../../../images/teacher5.png" },
        { name: "Margie Lowe", image: "../../../../../images/teacher6.png"},
        { name: "Ewan Phillips", image: "../../../../../images/teacher7.png" },
        { name: "Marrisa Burton", image: "../../../../../images/teacher8.png" },
        { name: "Britany O'Doherty", image: "../../../../../images/teacher9.png"}
    ];

}