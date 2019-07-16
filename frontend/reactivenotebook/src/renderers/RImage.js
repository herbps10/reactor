import React from 'react';
import { Resizable } from 're-resizable';
import styles from "./RImage.module.css";

const RImage = ({ cell, onImageLoad }) => (
    <Resizable
        className={styles.resizable}
        lockAspectRatio={true}>
        <img
            src={`http://localhost:5000/static/${cell.id}.svg?${cell.lastUpdate}`}
            onLoad={onImageLoad}
            className={styles.image} 
            alt="" />
    </Resizable>
);

export default RImage;
