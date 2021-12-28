import {LightningElement} from 'lwc';

export default class teachers extends LightningElement {

    showTeachers = true;

    myTeachers = [
        { name: "William Bermudez", image: "../../../resources/teacher1.png" },
        { name: "Suzanna Gianattasio", image: "../../../resources/teacher2.png" },
        { name: "Antonia Shachar", image: "../../../resources/teacher3.png"}
    ];

}