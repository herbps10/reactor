import React from 'react';
import { FixedSizeGrid as Grid } from 'react-window';
import AutoSizer from 'react-virtualized-auto-sizer';
import { Resizable } from 're-resizable';


class RMatrix extends React.Component {
    constructor(props) {
        super(props)
        this.state = { open: false };
    }

    render() {
        const data = this.props.data; //.slice(0, 5).map((x) => x.slice(0, 5));

        const Cell = ({ columnIndex, rowIndex, style }) => (
            <div style={style}>
                {data[rowIndex][columnIndex]}
            </div>
        )

        return (
            <Resizable defaultSize={{ height: 300 }}>
                <AutoSizer>
                    {({ width, height }) => (
                        <Grid
                            columnCount={data[0].length}
                            rowCount={data.length}
                            rowHeight={35}
                            height={height}
                            width={width}
                            columnWidth={data[0][0].toString().length * 15}
                        >
                            {Cell}
                        </Grid>
                    )}
                </AutoSizer>
            </Resizable>
        )
    }
}

export default RMatrix;