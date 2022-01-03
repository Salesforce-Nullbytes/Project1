import { LightningElement, wire } from 'lwc';
import createOrder from '@salesforce/apex/OrderController.createOrder'
export default class orderButton extends LightningElement {
    Order(){
        //console.log("Clicked order");
        //get selected toppings
        let toppings = [];
        var pepporoni = this.template.querySelector("input[name='peporoni']");
        if(pepporoni.checked){
            console.log(pepporoni.value);
            toppings.push(pepporoni.value);
        }
        var saussage = this.template.querySelector("input[name='saussage']");
        if(saussage.checked){
            console.log(saussage.value);
            toppings.push(saussage.value);
        }
        var mushroom = this.template.querySelector("input[name='mushroom']");
        if(mushroom.checked){
            console.log(mushroom.value);
            toppings.push(mushroom.value);
        }
        var greenPepper = this.template.querySelector("input[name='greenPepper']");
        if(greenPepper.checked){
            console.log(greenPepper.value);
            toppings.push(greenPepper.value);
        }
        var olive = this.template.querySelector("input[name='olive']");
        if(olive.checked){
            console.log(olive.value);
            toppings.push(olive.value);
        }


        //call createOrder()
        
        createOrder({'toppings':toppings})
            .then(response => {console.log(JSON.stringify(response))
            }).catch(e => {console.log(e)});
        //popup for conformation
    }
}