//
//  main.swift
//  Monitor
//
//  Created by Gary Barnett on 7/22/24.
//

import Cocoa

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
