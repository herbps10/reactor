import React from 'react';
import { FixedSizeGrid as Grid } from 'react-window';
import AutoSizer from 'react-virtualized-auto-sizer';
import { Resizable } from 're-resizable';



const RMatrix = (props) => {
    const data = props.data; //.slice(0, 5).map((x) => x.slice(0, 5));

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

export default RMatrix;