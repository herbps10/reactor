import {observable, decorate} from 'mobx';

class WebSocketService {
    connected = false;
    constructor() {
        this.socket = new WebSocket("ws://localhost:5000");    

        this.sendMessage = this.sendMessage.bind(this);
        this.onOpen = this.onOpen.bind(this);

        this.socket.addEventListener('open', this.onOpen);
    }
    onOpen() {
        this.connected = true;
    }
    sendMessage(message) {
        this.socket.send(message);
    }
    addReceiveListener(f) {
        this.socket.addEventListener('message', f);
    }
}

decorate(WebSocketService, { connected: observable });

export default WebSocketService;
