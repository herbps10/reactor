import {observable, decorate} from 'mobx';
import Cell from './Cell.js';

class CellStore {
    cells = [];

    constructor(webSocketService) {
        this.webSocketService = webSocketService;
        this.webSocketService.addReceiveListener(this.handleMessage.bind(this));
    }

    move(source, destination) {
        const payload = {
            type: 'move',
            source: this.cells[source].position,
            destination: source > destination ? destination + 0.5 : destination + 2
        };

        this.cells.splice(destination, 0, this.cells.splice(source, 1)[0]);
        this.cells.forEach((cell, index) => cell.position = index + 1)

        this.webSocketService.sendMessage(JSON.stringify(payload));
    }

    addCell(cell) {
        if(cell.position === undefined) {
            if(this.cells.length === 0) {
                cell.position = 1;
            }
            else {
                cell.position = this.cells[0].position + 1;
            }
        }
        this.cells.push(cell);
    }

    addCellBefore(cell, newCell) {
        const index = this.cells.indexOf(cell);
        this.cells.splice(index, 0, newCell);
        this.cells.forEach((cell, index) => cell.position = index + 1)
    }

    addCellAfter(cell, newCell) {
        const index = this.cells.indexOf(cell);
        this.cells.splice(index + 1, 0, newCell);
        this.cells.forEach((cell, index) => cell.position = index + 1)
    }

    deleteCell(cell) {
        this.cells = this.cells.filter(function(d) { return d !== cell; });
        this.cells.forEach((cell, index) => cell.position = index + 1)
        const payload = {
            type: 'delete',
            cell: cell
        }

        this.webSocketService.sendMessage(JSON.stringify(payload));
    }

    runCell(cell) {
        if(cell.value === "") {
            this.deleteCell(cell);
            return;
        }
        const payload = {
            type: 'update',
            cell: cell
        }
        this.webSocketService.sendMessage(JSON.stringify(payload));
    }

    updateView(cell, value) {
        const payload = {
            type: 'updateView',
            cell: cell,
            value: value
        };
        this.webSocketService.sendMessage(JSON.stringify(payload));
    }

    handleMessage(data) {
        const changeset = JSON.parse(data.data);

        if(changeset.cells !== undefined) {
          const cells = Object.values(changeset.cells);
          this.cells = [];
          for(let i = 0; i < cells.length; i++) {
            const change = cells[i];
            
            const cell = new Cell(change.value[0], "");
            cell.id = change.id[0];
            cell.RClass = change.RClass[0];
            cell.name = change.name[0];
            cell.result = change.result;
            cell.hasImage = change.hasImage[0];
            cell.position = change.position[0];

            this.addCell(cell);
          }

          if(cells.length === 0) {
            this.addCell(new Cell("", ""));
          }
        }
        else {
          if(changeset.error !== undefined) {
              const cell = this.cells.filter(function(d) {
                  return d.id === changeset.id[0];
              });

              cell[0].error = changeset.error;
              cell[0].result = [""];
              cell[0].RClass = "";
              cell[0].lastUpdate = new Date().getTime();
              cell[0].hasImage = false;
          }
          else {
              for(let i = 0; i < changeset.length; i++) {
                  const change = changeset[i];

                  const cell = this.cells.filter(function(d) {
                      return d.id === change.id[0];
                  });

                  if(change !== undefined) {
                    cell[0].result = change.result; 
                    cell[0].lastUpdate = new Date().getTime();
                    cell[0].hasImage = change.hasImage[0];
                    cell[0].RClass = change.RClass[0];
                    cell[0].name = change.name[0];
                    cell[0].error = "";
                    cell[0].position = change.position[0];
                  }
              }
          }
        }

    }
}

decorate(CellStore, { cells: observable });

export default CellStore;
