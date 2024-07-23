//
//  ConnectionHandler.swift
//  Monitor
//
//  Created by Gary Barnett on 7/22/24.
//

import Foundation

class ConnectionManager: NSObject, ObservableObject, ClientProtocol {
    private var _connection: NSXPCConnection!
    private var viewController:ViewController?
    
    private func establishConnection() -> Void
    {
        _connection = NSXPCConnection(serviceName: xpcServiceLabel)
        _connection.remoteObjectInterface = NSXPCInterface(with: XPCServiceProtocol.self)
        _connection.exportedObject = self
        _connection.exportedInterface = NSXPCInterface(with: ClientProtocol.self)
        _connection.interruptionHandler = {
            NSLog("Connection to XPC service interrupted")
        }
        
        _connection.invalidationHandler = {
            NSLog("Connection to XPC service invalidated")
            self._connection = nil
        }
        
        _connection.resume()
        
        NSLog("Connected to XPC service")
    }
    
    public func xpcService() -> XPCServiceProtocol
    {
        if _connection == nil {
            NSLog("NOT connected to XPC service")
            establishConnection()
        }
        
        return _connection.remoteObjectProxyWithErrorHandler { err in
            print(err)
        } as! XPCServiceProtocol
    }
    
    func invalidateConnection() -> Void {
        guard _connection != nil else { NSLog("no connection to invalidate"); return }
        
        _connection.invalidate()
    }
    
    func notifyFileEvent(data:[String:Any]) {
        DispatchQueue.main.async { [self] in
            viewController?.addEntry(json: data)
        }
        
    
        
    }
    
    func set(controller:ViewController?) {
        viewController = controller
    }
}
