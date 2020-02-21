//
//  User.swift
//  
//
//  Created by Leah Lundqvist on 2020-02-21.
//

public class User {
    var id:String = ""
    var username:String = ""
    var discrim:String = ""
    var avatarHash:String = ""
    var token:String = ""
    
    func from_payload(payload:String) {
        let values = payload.split(separator: ":")
        
        self.id = String(values[0])
        self.discrim = String(values[1])
        self.avatarHash = String(values[2])
        self.username = String(values[3])
    }
}
