import { LightningElement } from 'lwc';

export default class Gretting extends LightningElement {
    greeting= 'World';
    changeHandler(event){
        this.greeting= event.target.value;
    }
}