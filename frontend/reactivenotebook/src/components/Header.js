import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCircle } from '@fortawesome/free-solid-svg-icons';

class Header extends React.Component {
    render() {
        const connected = <FontAwesomeIcon icon={faCircle}  color={this.props.connected ? "#27ae60" : "#d35400"} />
        return (
            <div>ReactiveNotebook {connected}</div>
        )
    }
}

export default Header;