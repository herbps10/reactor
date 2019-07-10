import React from 'react';
import CodeMirror from 'react-codemirror';
import { Resizable } from 're-resizable';
import { observer } from 'mobx-react';
import { Draggable } from 'react-beautiful-dnd';
import ReactMarkdown from 'react-markdown';
import { BlockMath } from 'react-katex';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faPlay, faTrashAlt, faGripLines } from '@fortawesome/free-solid-svg-icons';
import RMatrix from "../renderers/RMatrix.js";
import AddCellButton from './AddCellButton.js';
import styles from "./CellItem.module.css";
import Cell from '../stores/Cell.js';
import "codemirror/lib/codemirror.css";
import "codemirror/theme/idea.css";
import 'katex/dist/katex.min.css';

import ('codemirror/mode/r/r');

const CellItem = observer(class CellItem extends React.Component {
    constructor(props) {
        super(props);

        this.instance = null;

        this.state = { active: true };

        this.containerRef = React.createRef();
        this.resultRef = React.createRef();
        this.codeMirrorRef = React.createRef();
        this.activateRef = React.createRef();

        this.addCellBefore = this.addCellBefore.bind(this);
        this.addCellAfter = this.addCellAfter.bind(this);
        this.delete = this.delete.bind(this);
        this.update = this.update.bind(this);
        this.run = this.run.bind(this);
        this.onKeyUp = this.onKeyUp.bind(this);
        this.onClick = this.onClick.bind(this);
        this.onDocumentClick = this.onDocumentClick.bind(this);
        this.onUpdateCell = this.onUpdateCell.bind(this);

        this.codeMirrorOptions = {
            viewportMargin: Infinity,
            lineNumbers: true,
            lineWrapping: true,
            mode: 'r',
            theme: 'idea',
            extraKeys: {
                "Shift-Enter": this.run
            }
        }
    }

    componentWillMount() {
        document.addEventListener('mousedown', this.onDocumentClick, false);
    }

    componentDidMount() {
        this.containerRef.current.addEventListener('update-cell', this.onUpdateCell, false);
        this.codeMirrorRef.current.focus();
    }

    componentWillUnmount() {
        document.removeEventListener('mousedown', this.onDocumentClick, false);
        this.containerRef.current.addEventListener('update-cell', this.onUpdateCell);
    }

    componentDidUpdate(prevProps, prevState) {
        if (prevState.active == false && this.state.active == true) {
            if (this.codeMirrorRef.current != null) {
                this.codeMirrorRef.current.getCodeMirror().display.input.textarea.focus();
            }
        }
    }

    onUpdateCell(e) {
        console.log(e);
    }

    onDocumentClick(e) {
        //if(e.target.isEqualNode(this.activateRef.current)) return;
        //if(!this.containerRef.current.contains(e.target)) this.setState({ active: false });
    }

    onClick(e) {
        console.log(this.state.active);
        this.setState({ active: !this.state.active });
    }

    addCellAfter() {
        this.setState({ active: false });
        this.props.store.addCellAfter(this.props.cell, new Cell("", ""));
    }

    addCellBefore() {
        this.setState({ active: false });
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
        if (e.keyCode == 13 && e.shiftKey) {
            this.run();
            e.preventDefault();
            e.stopPropagation();
        }
    }

    renderHTML() {
        const cellHTML = { __html: this.props.cell.resultString() };
        return <div dangerouslySetInnerHTML = { cellHTML }
        />;
    }

    resultView() {
        if (this.props.cell.hasImage) return null;

        if (this.props.cell.RClass === "md" && this.props.cell.result.length > 0)
            return <ReactMarkdown source = { this.props.cell.resultString() }
        escapeHtml = { false }
        />;

        if (this.props.cell.RClass === "html")
            return this.renderHTML();

        if (this.props.cell.RClass === "view")
            return <div dangerouslySetInnerHTML = {
                { __html: this.props.cell.resultString() } }
        />

        if (this.props.cell.RClass == "matrix") {
            return <RMatrix data = {this.props.cell.result} />;
    }

    if (this.props.cell.RClass == "latex") {
      return <BlockMath math={this.props.cell.resultString()} />;
    }

    const options = {
      readOnly: 'nocursor',
      mode: 'r',
      theme: 'idea',
      lineWrapping: false,
    };

    let value = "";
    if (this.props.cell.RClass == "function") {
      const f = this.props.cell.result[0].replace(/{$/, "");
      value = (this.props.cell.name == "" || this.props.cell.name == undefined) ?
        f
        : this.props.cell.name + ": " + f;
    }
    else {
      value = (this.props.cell.name == "" || this.props.cell.name == undefined) ?
        this.props.cell.resultString()
        : this.props.cell.name + ": " + this.props.cell.resultString();
    }

    if (this.resultRef.current != null) {
      this.resultRef.current.getCodeMirror().doc.setValue(value);
    }

    return (
      <div className={styles.resultContainer}>
        <CodeMirror ref={this.resultRef} value={value} options={options} />
      </div>
    )
  }

  render() {
    const image = this.props.cell.hasImage ? (
      <Resizable
        className={styles.resizable}
        lockAspectRatio={true}>
        <img
          src={`http://localhost:5000/static/${this.props.cell.id}.svg?${this.props.cell.lastUpdate}`}
          onLoad={this.onImageLoad}
          className={styles.image} />
      </Resizable>
    ) : null;

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
            >
              <div className={styles.activate} onClick={this.onClick} ref={this.activateRef} />
              <div className={styles.columns}>
                <AddCellButton onClick={this.addCellBefore} className={[styles.addCellBefore, styles.addCell, styles.buttonColor].join(' ')} />
                <div className={styles.grip}>
                  <a className={styles.gripHandle} {...provided.dragHandleProps}></a>
                </div>

                <div className={styles.editor}>
                  <CodeMirror
                    className={mirrorClasses}
                    value={this.props.cell.value}
                    onChange={this.update}
                    options={this.codeMirrorOptions}
                    ref={this.codeMirrorRef} />

                  <div className={styles.result}>
                    {error}
                    {result}
                    {image}
                  </div>

                  <div className={styles.actions}>
                    <button onClick={this.run} className={styles.buttonColor}><FontAwesomeIcon icon={faPlay} /></button>
                    <button onClick={this.delete} className={styles.buttonColor}><FontAwesomeIcon icon={faTrashAlt} /></button>
                  </div>
                </div>
                <AddCellButton onClick={this.addCellAfter} className={[styles.addCellAfter, styles.addCell, styles.buttonColor].join(' ')} />
              </div>
              <div className={styles.spacer} />
            </div>
          )}
        </Draggable>
      </div>
    )
  }
});

export default CellItem;