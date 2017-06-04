let channel, localVideo, btnBroadcast, localStream, socket
let connections = []

let servers = {
    "iceServers" : [
        {url: "stun:stun.l.google.com:19302"}
    ]
}

let anchor = {
    init(sock, element) {
        if (!element) {
            return
        } else {
            socket = sock
            this.init_ui()
        }
    },
    init_ui() {
        btnBroadcast = document.getElementById("broadcast")
        btnBroadcast.onclick = this.connect

        localVideo = document.getElementById("localVideo")
    },
    connect() {
        let user = {user: "anchor"}
        socket.connect(user)
        channel = socket.channel("room")
        channel.on("new_audience", payload => {
            anchor.onNewAudience(payload)
        })
        channel.on("sdp", payload => {
            anchor.onRemoteDescription(payload)
        })
        channel.join()
            .receive("ok", () => { 
                console.log("Successfully joined channel")
                anchor.onConnected()
            })
            .receive("error", () => { console.log("Unable to join") })
    },
    onConnected() {
        navigator.getUserMedia = (navigator.getUserMedia 
            || navigator.webkitGetUserMedia || navigator.mozGetUserMedia 
            || navigator.msGetUserMedia || navigator.oGetUserMedia)
        navigator.getUserMedia({video: true}, anchor.onSucceed, anchor.onError)
        btnBroadcast.disabled = true
    },
    onSucceed(stream) {
        localVideo.srcObject = stream
        localStream = stream
    },
    onError(error) {
        console.log(">>> ERROR: ", error)
    },
    onNewAudience(user) {
        console.log(">>> NEW AUDIENCE: ", user)

        let peerConnection = new RTCPeerConnection(servers)
        let connection = {
            name: user.user,
            conn: peerConnection
        }
        connections.push(connection)

        function getLocalDescription(desc) {
            peerConnection.setLocalDescription(desc, () => {
                channel.push("anchor_sdp", {to: user, body: JSON.stringify({
                    "sdp": peerConnection.localDescription
                })})
            }, anchor.onError)
        }
        peerConnection.onicecandidate = function(event) {
            if (event.candidate) {
                channel.push("anchor_candidate", {to: user, body: JSON.stringify({
                    "candidate": event.candidate
                })});
            }
        }
        peerConnection.addStream(localStream)
        peerConnection.createOffer(getLocalDescription, anchor.onError)        
    },
    onRemoteDescription(payload) {
        connections.forEach(function(x) {
            if (x.name == payload.origin) {
                let object = JSON.parse(payload.body)
                console.log(">>> AUDIENCE SDP: ", object.sdp)
                x.conn.setRemoteDescription(new RTCSessionDescription(object.sdp))
            }
        })
    }
}
export default anchor