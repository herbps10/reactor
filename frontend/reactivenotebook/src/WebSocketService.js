class WebSocketService {
    constructor() {
        this.socket = new WebSocket("ws://localhost:5000");    

        this.sendMessage = this.sendMessage.bind(this);
        this.onOpen = this.onOpen.bind(this);

        this.socket.addEventListener('open', this.onOpen);
    }
    onOpen() {
        console.log("onOpen");
    }
    sendMessage(message) {
        console.log(message);
        this.socket.send(message);
    }
    addReceiveListener(f) {
        this.socket.addEventListener('message', f);
    }
}

export default WebSocketService;