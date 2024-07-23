//
//  Protocols.swift
//  XPCService
//
//  Created by Gary Barnett on 7/22/24.
//

import Foundation

let xpcServiceLabel = "com.gbcs.XPCService"

@objc protocol XPCServiceProtocol {
    func startWatching() -> Void
    func stopWatching() -> Void
}

@objc protocol ClientProtocol {
    func notifyFileEvent(data:[String:Any]) -> Void
}
