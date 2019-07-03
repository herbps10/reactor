import React from 'react';
import { observer } from 'mobx-react';
import CellItem from './CellItem.js';
import styles from "./CellList.module.css";

const CellList = observer(class CellList extends React.Component {
    constructor(props) {
        super(props);
    }
    render() {
        const cells = this.props.store.cells.map((cell) => (
            <div key={cell.id}>
                <CellItem cell={cell} store={this.props.store} key={cell.id} />
            </div>
        ) );

        return (
            <div>
                {cells}
            </div>
        );
    }
});

export default CellList;