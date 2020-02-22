//
//  File.swift
//  
//
//  Created by Leah Lundqvist on 2020-02-21.
//

public extension DisQR {
    public class Messages {
        static var HEARTBEAT = "heartbeat"
        static var HELLO = "hello"
        static var INIT = "init"
        static var NONCE_PROOF = "nonce_proof"
        static var PENDING_REMOTE_INIT = "pending_remote_init"
        static var PENDING_FINISH = "pending_finish"
        static var FINISH = "finish"
        
        public static func json_op(message:String) -> String {
            return "{\"op\":\"\(message)\"}"
        }
        
        public static func json(op:String, key:String, value:String) -> String {
            return "{\"op\":\"\(op)\",\"\(key)\":\"\(value)\"}"
        }
    }
}
