import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPlus } from '@fortawesome/free-solid-svg-icons';
import styles from './AddCellButton.module.css';

const AddCellButton = (props) => {
    return (<button className={props.className} onClick={props.onClick}><FontAwesomeIcon icon={faPlus} /></button>);
};

export default AddCellButton;