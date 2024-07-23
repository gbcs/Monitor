//
//  AppDelegate.swift
//  Monitor
//
//  Created by Gary Barnett on 7/22/24.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow!
    private var statusItem: NSStatusItem!
    private var windowItem:NSMenuItem?
    private var connectionHandler = ConnectionManager()
    private var viewController:ViewController = ViewController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 270),
            styleMask: [.miniaturizable, .resizable, .titled],
            backing: .buffered, defer: false)
        
        window.contentViewController = viewController
        connectionHandler.set(controller: viewController)
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "filemenu.and.selection", accessibilityDescription: "Monitor")
        }
        
        let appMenu = NSMenu()
        
        appMenu.addItem(withTitle: "About", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        
        appMenu.addItem(NSMenuItem.separator())
        windowItem = NSMenuItem(title: "Open Window", action: #selector(toggleWindow), keyEquivalent: "w")
        
        if let windowItem {
            appMenu.addItem(windowItem)
        }
        
        statusItem.menu = appMenu
        
        connectionHandler.xpcService().startWatching()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @objc func toggleWindow() {
        if window == nil { return }
        
        if window.isVisible {
            windowItem?.title = "Open Window"
            removeWindow()
        } else {
            windowItem?.title = "Close Window"
            showWindow()
        }
    }
    
    func removeWindow() {
        window?.orderOut(self)
    }
    
    func showWindow() {
        if let window {
            window.center()
            window.title = "Monitor - Event Display"
            window.makeKeyAndOrderFront(nil)
        }
    }
}

