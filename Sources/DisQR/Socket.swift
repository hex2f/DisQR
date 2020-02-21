//
//  Socket.swift
//  
//
//  Created by Leah Lundqvist on 2020-02-21.
//

import Foundation
import Starscream
import SwiftyJSON

public enum SocketState {
    case disconnected
    case connecting
    case connected
}

public typealias SocketHandlerFunc = (JSON) -> Void

public class Socket: WebSocketDelegate {
    var request:URLRequest = URLRequest(url: URL(string: "wss://remote-auth-gateway.discord.gg/?v=1")!)
    var ws: WebSocket
    
    var state: SocketState = SocketState.disconnected
    var handlers:[String:SocketHandlerFunc] = [:]
    
    init() {
        self.ws = WebSocket(request: request)
        self.ws.delegate = self
    }
    
    func setHandlers(handlers:[String:SocketHandlerFunc]) {
        self.handlers = handlers
    }
    
    func connect() {
        self.state = .connecting
        self.ws.connect()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(_):
            self.state = .connected
            if self.handlers["connected"] != nil { self.handlers["connected"]!(JSON()) }
        case .disconnected(_, _):
            self.state = .disconnected
            if self.handlers["disconnected"] != nil { self.handlers["disconnected"]!(JSON()) }
        case .text(let string):
            do {
                let json = try JSON(data: string.data(using: .utf8, allowLossyConversion: false)!)
                print(json)
                if self.handlers[json["op"].stringValue] != nil { self.handlers[json["op"].stringValue]!(json) }
            } catch {
                print(error)
            }
        case .binary(_):
            break;
        case .ping(_):
            break
        case .pong(_):
            break
        case .viablityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            self.state = .disconnected
        case .error:
            self.state = .disconnected
        }
    }
}
