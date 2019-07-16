import React from 'react';
import { FixedSizeGrid as Grid } from 'react-window';
import AutoSizer from 'react-virtualized-auto-sizer';
import { Resizable } from 're-resizable';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCaretRight, faCaretUp } from '@fortawesome/free-solid-svg-icons';
import styles from './RMatrix.module.css';


class RMatrix extends React.Component {
    constructor(props) {
        super(props)
        this.state = { open: false };
        this.onClick = this.onClick.bind(this);
    }

    onClick() {
        this.setState({ open: !this.state.open });
    }

    render() {
        const data = this.props.cell.result;
        const rowLabelClasses = [styles.label, styles.rowLabel].join(' ');
        const Cell = function({ columnIndex, rowIndex, style }) {
            if(columnIndex == 0 && rowIndex == 0) {
                return <div style={style} className={styles.label}></div>;
            }
            else if(columnIndex == 0) {
                return (
                    <div style={style} className={rowLabelClasses}>
                        <span>{rowIndex}</span>
                    </div>
                );
            }
            else if(rowIndex == 0) {
                return (
                    <div style={style} className={styles.label}>
                        <span>{columnIndex}</span>
                    </div>
                );
            }
            else {
                return (
                    <div style={style}>
                        <span>{data[rowIndex - 1][columnIndex - 1]}</span>
                    </div>
                );
            }
        };

        const matrixView = (
            <Resizable defaultSize={{ height: 300 }}>
                <AutoSizer>
                    {({ width, height }) => (
                        <Grid
                            columnCount={data[0].length + 1}
                            rowCount={data.length + 1}
                            rowHeight={25}
                            height={height}
                            width={width - 20}
                            columnWidth={data[0][0].toString().length * 15}
                            className={styles.grid}
                        >
                            {Cell}
                        </Grid>
                    )}
                </AutoSizer>
            </Resizable>
        );

        return (
            <div>
                <pre className={styles.pre}>{this.props.cell.name}: matrix({this.props.cell.result.length}, {this.props.cell.result[0].length})</pre>
                <button onClick={this.onClick} className={styles.toggle}>
                    <FontAwesomeIcon icon={this.state.open ? faCaretUp : faCaretRight} />
                </button>
                {this.state.open ? matrixView : null}
            </div>
        )
    }
}

export default RMatrix;