import {observable, decorate} from 'mobx';

class CellStore {
    cells = [];

    constructor(webSocketService) {
        this.webSocketService = webSocketService;
        this.webSocketService.addReceiveListener(this.handleMessage.bind(this));
    }

    addCell(cell) {
        this.cells.push(cell);
    }

    addCellBefore(cell, newCell) {
        const index = this.cells.indexOf(cell);
        this.cells.splice(index, 0, newCell);
    }

    addCellAfter(cell, newCell) {
        const index = this.cells.indexOf(cell);
        this.cells.splice(index + 1, 0, newCell);
    }

    deleteCell(cell) {
        this.cells = this.cells.filter(function(d) { return d != cell; });
    }

    runCell(cell) {
        console.log("Sending", cell);
        this.webSocketService.sendMessage(JSON.stringify(cell));
    }

    handleMessage(data) {
        const changeset = JSON.parse(data.data);

        if(changeset.error != undefined) {
            const cell = this.cells.filter(function(d) {
                return d.id == changeset.id[0];
            });

            cell[0].error = changeset.error[0];
            cell[0].result = "";
            cell[0].lastUpdate = new Date().getTime();
            cell[0].hasImage = false;
        }
        else {
            for(let i = 0; i < changeset.length; i++) {
                const change = changeset[i];

                const cell = this.cells.filter(function(d) {
                    return d.id == change.id[0];
                });

                console.log("Change", change);

                cell[0].result = change.result; 
                cell[0].lastUpdate = new Date().getTime();
                cell[0].hasImage = change.hasImage[0];
                cell[0].error = "";
            }
        }

    }
}

decorate(CellStore, { cells: observable });

export default CellStore;