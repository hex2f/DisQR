//
//  User.swift
//  
//
//  Created by Leah Lundqvist on 2020-02-21.
//

public extension DisQR {
    public class User {
        public var id:String = ""
        public var username:String = ""
        public var discrim:String = ""
        public var avatarHash:String = ""
        public var token:String = ""
        
        func from_payload(payload:String) {
            let values = payload.split(separator: ":")
            
            self.id = String(values[0])
            self.discrim = String(values[1])
            self.avatarHash = String(values[2])
            self.username = String(values[3])
        }
    }
}
