//
//  ViewController.swift
//  Monitor
//
//  Created by Gary Barnett on 7/22/24.
//

import Cocoa
import UserNotifications

class ViewController: NSViewController {
    let gridView = NSGridView(views: [
               [NSTextField(labelWithString: ""), NSTextField(labelWithString: ""), NSTextField(labelWithString: ""), NSTextField(labelWithString: "")],
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Notifications Enabled")
            } else {
                print("Notifications Not Available")
            }
        }
        gridView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = gridView
        scrollView.hasVerticalScroller = true
        
        self.view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            gridView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let column = gridView.column(at: 0)
        column.width = 200
        
        let column2 = gridView.column(at: 1)
        column2.width = 100
        
        let column3 = gridView.column(at: 2)
        column3.width = 100
        
        let column4 = gridView.column(at: 3)
        column4.width = 200
    }
    
    func addEntry(json:[String:Any]) {
        var path:String = ""
        var fileId = 0
        var flags = 0
        if let p = json["path"] as? [String : Any] {
            path = p["path"] as! String
            fileId = p["fileID"] as! Int
        }
        flags = json["flags"] as! Int
        
        var decodedFlags = ""
        
        if kFSEventStreamEventFlagItemRenamed & flags != 0 {
            decodedFlags += "Rename "
        }
        
        if kFSEventStreamEventFlagItemModified & flags != 0 {
            decodedFlags += "Modify"
        }
        
        if kFSEventStreamEventFlagItemChangeOwner & flags != 0 {
            decodedFlags += "Chown "
        }
        
        if kFSEventStreamEventFlagItemXattrMod & flags != 0 {
            decodedFlags += "AttrMod "
        }
        
        if kFSEventStreamEventFlagItemIsFile & flags != 0 {
            decodedFlags += "IsFile "
        }
        
        if kFSEventStreamEventFlagItemIsDir & flags != 0 {
            decodedFlags += "IsDir "
        }
        
        if kFSEventStreamEventFlagItemIsSymlink & flags != 0 {
            decodedFlags += "IsSymLnk "
        }

        gridView.addRow(with: [NSTextField(labelWithString: path),
                               NSTextField(labelWithString: String(fileId)),
                               NSTextField(labelWithString: String(flags)),
                                NSTextField(labelWithString: decodedFlags)
                              ]
        )
        
        
        
        if gridView.numberOfRows > 1000 {
            gridView.removeRow(at: 0)
        }
        
        notifyUser(path: path, flags: decodedFlags)
        
    }
    
    func notifyUser(path:String, flags:String) {
        let content = UNMutableNotificationContent()
        content.title = "File Monitor"
        content.body = path + " " + flags
        let request = UNNotificationRequest(identifier: "com.gbcs.monitor.file", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

