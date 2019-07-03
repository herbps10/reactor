import React from 'react';
import CodeMirror from 'react-codemirror';
import { observer } from 'mobx-react';
import ReactMarkdown from 'react-markdown';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPlay, faTrashAlt } from '@fortawesome/free-solid-svg-icons';
import AddCellButton from './AddCellButton.js';
import "codemirror/lib/codemirror.css";
import "codemirror/theme/idea.css";
import styles from "./CellItem.module.css";
import Cell from '../stores/Cell.js';

import('codemirror/mode/r/r');

const CellItem = observer(class CellItem extends React.Component {
    constructor(props) {
        super(props);
        
        this.addCellBefore = this.addCellBefore.bind(this);
        this.addCellAfter = this.addCellAfter.bind(this);
        this.delete = this.delete.bind(this);
        this.update = this.update.bind(this);
        this.run = this.run.bind(this);
        this.onKeyUp = this.onKeyUp.bind(this);

        this.codeMirrorOptions = {
            viewportMargin: Infinity,
            lineNumbers: true,
            mode: 'r',
            theme: 'idea',
            extraKeys: {
                "Shift-Enter": this.run
            }
        }
    }

    addCellAfter() {
        this.props.store.addCellAfter(this.props.cell, new Cell("", ""));
    }

    addCellBefore() {
        this.props.store.addCellBefore(this.props.cell, new Cell("", ""));
    }

    delete() {
        this.props.store.deleteCell(this.props.cell);
    }

    update(newValue) {
        this.props.cell.value = newValue;
    }

    run() {
        this.props.store.runCell(this.props.cell);
    }

    onKeyUp(e) {
        if(e.keyCode == 13 && e.shiftKey) {
            this.run();
            e.preventDefault();
            e.stopPropagation();
        }
    }

    resultView() {
        if(this.props.cell.hasImage) return null;
        if(this.props.cell.RClass == "md" && this.props.cell.renderResult().length > 0)
            return <ReactMarkdown source={this.props.cell.renderResult().join("\n")} />
        return (
            <pre>
                {this.props.cell.renderResult()}
            </pre>
        )
    }

    render() {
        const image = this.props.cell.hasImage ? <img 
            src={`http://localhost:5000/static/${this.props.cell.id}.svg?${this.props.cell.lastUpdate}`}
            onLoad={this.onImageLoad}
            className={styles.image} /> : null;

        const result = this.resultView();
        const error = this.props.cell.error == "" ? null : (
            <div className={styles.error}>{this.props.cell.error}</div>
        );

        return (
            <div className={styles.cell}>
                <AddCellButton onClick={this.addCellBefore} className={[styles.addCellBefore, styles.addCell, styles.buttonColor].join(' ')} />
                <div className={styles.columns}>
                    <div className={styles.actions}>
                        <button onClick={this.run} className={styles.buttonColor}><FontAwesomeIcon icon={faPlay} /></button>
                        <button onClick={this.delete} className={styles.buttonColor}><FontAwesomeIcon icon={faTrashAlt} /></button>
                    </div>

                    <div className={styles.editor}>
                        <CodeMirror
                            className={styles.mirror}
                            value={this.props.cell.value}
                            onChange={this.update}
                            options={this.codeMirrorOptions} />

                        <div className={styles.result}>
                            {error}
                            {result}
                            {image}
                        </div>
                    </div>
                </div>
                <AddCellButton onClick={this.addCellAfter} className={[styles.addCellAfter, styles.addCell, styles.buttonColor].join(' ')} />
            </div>
        )
    }
});

export default CellItem;