import React from 'react';
import CellList from './components/CellList.js';
import { observer } from 'mobx-react';
import { DragDropContext } from 'react-beautiful-dnd';
import Header from './components/Header.js';
import './App.css';

const App = observer(class App extends React.Component {
  constructor(props) {
    super(props);
    this.onDragEnd = this.onDragEnd.bind(this);
  }

  onDragEnd(result) {
    if(
      result.source !== null && result.destination !== null &&
      result.source.index !== result.destination.index
    ) {
      console.log(result.source.index, result.destination.index);
      this.props.store.move(result.source.index, result.destination.index);
    }
  }

  render() {
    return (
      <DragDropContext onDragEnd={this.onDragEnd}>
        <div className="App">
          <header className="App-header">
            <Header connected={this.props.store.webSocketService.connected} />
          </header>
          <CellList store={this.props.store} />
        </div>
     </DragDropContext>
    );
  }
});

export default App;
