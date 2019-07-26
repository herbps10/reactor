import React from 'react';
import { Resizable } from 're-resizable';
import styles from "./RHtmlWidget.module.css";

const RHtmlWidget = ({ cell }) => (
    <Resizable
        className={styles.resizable}>
       <iframe
            src={`http://localhost:5000/static/${cell.id}.html?${cell.lastUpdate}`}
            width='100%'
            height='100%'
            className={styles.iframe} />
    </Resizable>
);

export default RHtmlWidget;