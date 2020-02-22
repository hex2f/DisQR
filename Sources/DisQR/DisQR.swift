import SwiftyJSON

public struct DisQR {
    public enum State {
        case uninitialized
        case initializing
        case initialized
        case pending
        case failed
        case success
    }

    public class Authenticator {
        var handlers:[String:SocketHandlerFunc] = [:]
        
        var socket:Socket
        var crypto:Crypto
        
        public var stateChanged: (() -> Void)?
        public var state:State = .uninitialized {
            didSet {
                stateChanged?()
            }
        }
        
        public var user:User?
        public var fingerprint:String?
        
        public init() throws {
            self.crypto = try Crypto()
            self.socket = Socket()
        }
        
        public func start() {
            self.state = .initializing
            self.handlers = [
                "connected": self.init_socket,
                "disconnected": self.handle_disconnect,
                "nonce_proof": self.prove_nonce,
                "pending_remote_init": self.receive_fingerprint,
                "pending_finish": self.receive_user,
                "finish": self.finish,
            ]
            self.socket.setHandlers(handlers: self.handlers)
            self.socket.connect()
        }
        
        func init_socket(_:JSON) {
            // Send out public key encoded as base64 to the socket.
            self.socket.ws.write(
                string: Messages.json(
                    op: Messages.INIT,
                    key: "encoded_public_key",
                    value: self.crypto.publicBase64
            ))
        }
        
        func handle_disconnect(_:JSON) {

        }
        
        func prove_nonce(json:JSON) {
            // Decrypt the incoming nonce
            guard let decrypted = self.crypto.decrypt(data: json["encrypted_nonce"].stringValue) else {
                return self.state = .failed
            }
            
            // SHA256 hash the decrypted nonce and encoded is as urlsafe
            let proof = Crypto.base64Encode(Crypto.sha256(data: decrypted))
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
            
            // Send the nonce hash to the socket.
            self.socket.ws.write(
                string: Messages.json(
                    op: Messages.NONCE_PROOF,
                    key: "proof",
                    value: proof
            ))
        }
        
        func receive_fingerprint(json:JSON) {
            // Try getting the fingerprint from json, if it's nil, set state to failed
            guard let fingerprint = json["fingerprint"].string else {
                return self.state = .failed
            }
            
            self.fingerprint = fingerprint
            
            self.state = .initialized
        }
        
        func receive_user(json:JSON) {
            // Try getting the user payload, if it's nil, set state to failed
            guard let payload = self.crypto.decrypt(data: json["encrypted_user_payload"].stringValue) else {
                return self.state = .failed
            }
            
            // Create a User from the user payload
            let user = User()
            user.from_payload(payload: String(decoding: payload, as: UTF8.self))
            self.user = user
            
            self.state = .pending
        }
        
        func finish(json:JSON) {
            // Try getting the token, if it's nil, set state to failed
            guard let token = self.crypto.decrypt(data: json["encrypted_token"].stringValue) else {
                return self.state = .failed
            }
            
            // Update the token on the User
            self.user!.token = String(decoding: token, as: UTF8.self)
            
            self.state = .success
        }
    }
}
