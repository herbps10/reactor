import {observable, decorate} from 'mobx';
import Cell from './Cell.js';

class CellStore {
    cells = [];

    constructor(webSocketService) {
        this.webSocketService = webSocketService;
        this.webSocketService.addReceiveListener(this.handleMessage.bind(this));
    }

    swap(source, destination) {
      this.cells.splice(destination, 0, this.cells.splice(source, 1)[0]);
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
        const payload = {
            type: 'delete',
            cell: cell
        }

        this.webSocketService.sendMessage(JSON.stringify(payload));
    }

    runCell(cell) {
        if(cell.value == "") {
            this.deleteCell(cell);
        }
        const payload = {
            type: 'update',
            cell: cell
        }
        console.log(payload);
        this.webSocketService.sendMessage(JSON.stringify(payload));
    }

    handleMessage(data) {
        const changeset = JSON.parse(data.data);

        if(changeset.cells != undefined) {
          const cells = Object.values(changeset.cells);
          this.cells = [];
          for(let i = 0; i < cells.length; i++) {
            const change = cells[i];
            
            const cell = new Cell(change.value[0], "");
            cell.id = change.id[0];
            cell.RClass = change.RClass[0];
            cell.name = change.name[0];
            cell.result = change.result[0];
            cell.hasImage = change.hasImage[0];

            this.addCell(cell);
          }

          if(cells.length == 0) {
            this.addCell(new Cell("", ""));
          }
        }
        else {
          if(changeset.error != undefined) {
              const cell = this.cells.filter(function(d) {
                  return d.id == changeset.id[0];
              });

              cell[0].error = changeset.error[0];
              cell[0].result = "";
              cell[0].RClass = "";
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

                  cell[0].result = change.result[0]; 
                  cell[0].lastUpdate = new Date().getTime();
                  cell[0].hasImage = change.hasImage[0];
                  cell[0].RClass = change.RClass[0];
                  cell[0].name = change.name[0];
                  cell[0].error = "";
              }
          }
        }

    }
}

decorate(CellStore, { cells: observable });

export default CellStore;
