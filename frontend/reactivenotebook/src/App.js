import React from 'react';
import CellList from './CellList.js';
import Cell from './Cell.js';
import { observer } from 'mobx-react';
import './App.css';

const App = observer(class App extends React.Component {
  constructor(props) {
    super(props);
  }
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <CellList store={this.props.store} />
        </header>
      </div>
    );
  }
});

export default App;
