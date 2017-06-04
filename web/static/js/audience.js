let channel, remoteVideo, peerConnection, remoteStream
let btnWatch, socket
let count = 0

let servers = {
    "iceServers" : [
        {url: "stun:stun.l.google.com:19302"}
    ]
}

let unique = "audience_" + Math.floor((Math.random() * 100) + 1)

let audience = {
    init(sock, element) {
        if (!element) {
            return
        } else {
            socket = sock
            this.init_ui()
        }
    },
    init_ui() {
        btnWatch = document.getElementById("watch")
        btnWatch.onclick = this.connect

        remoteVideo = document.getElementById("remoteVideo")
    },
    connect() {
        let user = {user: unique}
        socket.connect(user)
        channel = socket.channel("room")
        channel.on("sdp", payload => {
            audience.onRemoteDescription(JSON.parse(payload.body))
        })
        channel.on("candidate", payload => {
            audience.onRemoteCandidate(JSON.parse(payload.body))
        })
        channel.join()
            .receive("ok", () => {console.log("Successfully joined channel") })
            .receive("error", () => { console.log("Unable to join") })
        btnWatch.disabled = true
        peerConnection = new RTCPeerConnection(servers)
        peerConnection.onaddstream = audience.onRemoteStream
    },
    onError(error) {
        console.log(">>> ERROR: ", error)
    },
    getLocalDescription(desc) {
        peerConnection.setLocalDescription(desc, () => {
            channel.push("audience_sdp", { body: JSON.stringify({
                "sdp": peerConnection.localDescription
            })});
        }, audience.onError);
    },
    onRemoteDescription(rdesc) {
        console.log(">>> SDP: ", rdesc.sdp)
        peerConnection.setRemoteDescription(new RTCSessionDescription(rdesc.sdp))
        peerConnection.createAnswer(audience.getLocalDescription, audience.onError)
    },
    onRemoteCandidate(event) {
        console.log(">>> CANDIDATE: ", event.candidate)
        if (event.candidate) {
            peerConnection.addIceCandidate(new RTCIceCandidate(event.candidate));
        }
    },
    onRemoteStream(event) {
        remoteStream = event.stream
        remoteVideo.srcObject = remoteStream
    }
}
export default audience