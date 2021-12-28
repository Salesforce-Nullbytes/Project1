import {LightningElement} from 'lwc';

export default class teachers extends LightningElement {

    showTeachers = true;

    myTeachers = [
        { name: "William Bermudez", image: "../../../../../images/teacher1.png" },
        { name: "Suzanna Gianattasio", image: "../../../../../images/teacher2.png" },
        { name: "Antonia Shachar", image: "../../../../../images/teacher3.png"}
    ];

}