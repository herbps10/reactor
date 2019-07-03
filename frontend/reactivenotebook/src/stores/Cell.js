import {observable, decorate} from 'mobx';
const uuidv1 = require("uuid/v1");

class Cell {
    value = "";
    result = "";
    error = "";
    RClass = "";
    hasImage = false;
    constructor(value, result) {
        this.id = uuidv1();
        this.value = value;
        this.result = result;
        this.lastUpdate = new Date().getTime();
    }

    renderResult() {
        return this.result;
    }
}

decorate(Cell, {
    value: observable,
    result: observable,
    lastUpdate: observable,
    hasImage: observable,
    error: observable
})

export default Cell;