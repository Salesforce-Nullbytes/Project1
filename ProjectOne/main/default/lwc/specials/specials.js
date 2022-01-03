import { LightningElement } from 'lwc';
import PizzaLarge from '@salesforce/resourceUrl/PizzaLarge';
import PizzaTwo from '@salesforce/resourceUrl/PizzaTwo';
export default class specials extends LightningElement {
    LargePizza = PizzaLarge;
    TwoPizzas = PizzaTwo;
    show = true;

    hide() {
        this.show = !this.show;
    }
}
