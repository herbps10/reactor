import React from 'react';
import { observer } from 'mobx-react';
import { Droppable } from 'react-beautiful-dnd';
import CellItem from './CellItem.js';
import styles from "./CellList.module.css";

const CellList = observer(class CellList extends React.Component {
    constructor(props) {
        super(props);
    }
    render() {
        const cells = this.props.store.cells.map((cell, index) => (
            <div key={cell.id}>
                <CellItem cell={cell} store={this.props.store} key={cell.id} index={index} />
            </div>
        ) );

        return (
            <Droppable droppableId="cell-droppable">
                {(provided, snapshot) => (
                    <div
                        ref={provided.innerRef}
                        {...provided.droppableProps}
                    >
                        {cells}
                        {provided.placeholder}
                    </div>
                )}
            </Droppable>
        );
    }
});

export default CellList;
