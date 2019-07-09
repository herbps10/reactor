import React from 'react';
import { UnControlled as CodeMirror } from 'react-codemirror2';
import { observer } from 'mobx-react';
import { Draggable } from 'react-beautiful-dnd';
import ReactMarkdown from 'react-markdown';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPlay, faTrashAlt, faGripLines } from '@fortawesome/free-solid-svg-icons';
import AddCellButton from './AddCellButton.js';
import styles from "./CellItem.module.css";
import Cell from '../stores/Cell.js';
import "codemirror/lib/codemirror.css";
import "codemirror/theme/idea.css";

import('codemirror/mode/r/r');

const CellItem = observer(class CellItem extends React.Component {
    constructor(props) {
        super(props);

        this.instance = null;

        this.state = { active: true, value: this.props.cell.value };

        this.containerRef = React.createRef();
        this.resultRef = React.createRef();
        this.codeMirrorRef = React.createRef();
        
        this.addCellBefore = this.addCellBefore.bind(this);
        this.addCellAfter = this.addCellAfter.bind(this);
        this.delete = this.delete.bind(this);
        this.update = this.update.bind(this);
        this.run = this.run.bind(this);
        this.onKeyUp = this.onKeyUp.bind(this);
        this.onClick = this.onClick.bind(this);
        this.onUpdateCell = this.onUpdateCell.bind(this);

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

    componentWillMount() {
        document.addEventListener('mousedown', this.onClick, false);
    }

    componentDidMount() {
        this.containerRef.current.addEventListener('update-cell', this.onUpdateCell, false);
    }

    componentWillUnmount() {
        document.removeEventListener('mousedown', this.onClick, false);
        this.containerRef.current.addEventListener('update-cell', this.onUpdateCell);
    }

    componentDidUpdate(prevProps, prevState) {
      if(prevState.active == false && this.state.active == true) {
        if(this.instance != null) {
          this.instance.focus();
          //const cm = this.resultRef.current.getCodeMirror();
          //cm.focus();
          //cm.setCursor(cm.lineCount(), 0);
          //this.resultRef.current.getCodeMirror().doc.focus();
        }
      }
    }

    onUpdateCell(e) {
      console.log(e);
    }

    onClick(e) {
        if(this.containerRef.current.contains(e.target)) {
          this.setState({ active: true });
        }
        else {
          this.setState({ active: false });
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

    update(editor, data, newValue) {
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

    renderHTML() {
      const cellHTML = { __html: this.props.cell.result };
      return <div dangerouslySetInnerHTML={cellHTML} />;
    }

    resultView() {
        if(this.props.cell.hasImage) return null;

        if(this.props.cell.RClass === "md" && this.props.cell.result.length > 0)
            return <ReactMarkdown source={this.props.cell.result} />;

        if(this.props.cell.RClass === "html")
            return this.renderHTML();

        if(this.props.cell.RClass === "view")
            return <div dangerouslySetInnerHTML={{ __html: this.props.cell.result}} />

        const options = { readOnly: 'nocursor', mode: 'r', theme: 'idea' };

        const value = (this.props.cell.name == "" || this.props.cell.name == undefined) ? 
            this.props.cell.result
          : this.props.cell.name + ": " + this.props.cell.result;

        if(this.resultRef.current != null) {
          //this.resultRef.current.getCodeMirror().doc.setValue(value);
        }

        return (
          <CodeMirror ref={this.resultRef} value={value} options={options} />
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

        const cellClasses = [styles.cell, this.state.active ? styles.active : null].join(' ');
        const mirrorClasses = [styles.mirror, this.state.active ? styles.mirrorActive : styles.mirrorInactive].join(' ');

        return (
          <div ref={this.containerRef}>
            <Draggable key={this.props.cell.id} draggableId={`draggable-${this.props.cell.id}`} index={this.props.index}>
              {(provided, snapshot) => (
                <div className={cellClasses}
                  ref={provided.innerRef}
                  {...provided.draggableProps}
                  onClick={this.onClick}
                >
                    <AddCellButton onClick={this.addCellBefore} className={[styles.addCellBefore, styles.addCell, styles.buttonColor].join(' ')} />
                    <div className={styles.columns}>
                        <div className={styles.actions}>
                            <a className={styles.gripHandle} {...provided.dragHandleProps}></a>
                            <button onClick={this.run} className={styles.buttonColor}><FontAwesomeIcon icon={faPlay} /></button>
                            <button onClick={this.delete} className={styles.buttonColor}><FontAwesomeIcon icon={faTrashAlt} /></button>
                        </div>

                        <div className={styles.editor}>
                            <CodeMirror
                                className={mirrorClasses}
                                value={this.props.cell.value}
                                onChange={this.update}
                                options={this.codeMirrorOptions}
                                ref={this.codeMirrorRef}
                                editorDidMount={editor => { this.instance = editor }}/>

                            <div className={styles.result}>
                                {error}
                                {result}
                                {image}
                            </div>
                        </div>
                    </div>
                    <AddCellButton onClick={this.addCellAfter} className={[styles.addCellAfter, styles.addCell, styles.buttonColor].join(' ')} />
                </div>
              )}
            </Draggable>
          </div>
        )
    }
});

export default CellItem;
