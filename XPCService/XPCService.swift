//
//  XPCService.swift
//  XPCService
//
//  Created by Gary Barnett on 7/22/24.
//

import Foundation

class XPCService : NSObject, NSXPCListenerDelegate, XPCServiceProtocol
{
    private var pathList: [String] =  ["/Applications"]
    private var stream: FSEventStreamRef?
    
    let listener : NSXPCListener
    var connection : NSXPCConnection?
    
    override init()
    {
        listener = NSXPCListener(machServiceName: xpcServiceLabel)
        super.init()
        listener.delegate = self
    }
    
    func start() {
        listener.resume()
    }
    
    func stop() {
        listener.suspend()
    }
    
    var clientApp : ClientProtocol {
        return connection!.remoteObjectProxyWithErrorHandler { err in
            print(err)
        } as! ClientProtocol
    }
    
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedObject = self
        newConnection.exportedInterface = NSXPCInterface(with: XPCServiceProtocol.self)
        newConnection.remoteObjectInterface = NSXPCInterface(with: ClientProtocol.self)
        newConnection.resume()
        connection = newConnection
        return true
    }
    
    deinit {
        stopWatching()
    }
    
    func startWatching() {
        let paths = pathList as CFArray
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        var callbackContext = FSEventStreamContext(
            version: 0,
            info: context,
            retain: nil,
            release: nil,
            copyDescription: nil
        )

        let callback: FSEventStreamCallback = { (streamRef, clientCallBackInfo, numEvents, eventPaths, eventFlags, eventIds) in
            guard let info = clientCallBackInfo else { return }
            
            let paths = Unmanaged<CFArray>.fromOpaque(eventPaths).takeUnretainedValue() as! [NSDictionary]
            let classInstance = Unmanaged<XPCService>.fromOpaque(info).takeUnretainedValue()

            for i in 0..<numEvents {
                let path = paths[i]
                let flags = eventFlags[i]
                let id = eventIds[i]
                
                let event: [String: Any] = [
                    "path": path,
                    "flags": flags,
                    "id": id
                ]
                
                classInstance.clientApp.notifyFileEvent(data: event)
            }
        }
        
        let flags = kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseExtendedData
        
        stream = FSEventStreamCreate(nil,
                                     callback,
                                     &callbackContext,
                                     paths,
                                     FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
                                     1,
                                     FSEventStreamCreateFlags(flags)
        )
        FSEventStreamSetDispatchQueue(stream!, DispatchQueue.init(label: "watching"))
        FSEventStreamStart(stream!)
    }
    
    func stopWatching() {
        if let stream = stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
            self.stream = nil
        }
    }
}

