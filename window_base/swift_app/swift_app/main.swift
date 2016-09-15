//
//  main.swift
//  swift_app
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

// swiftc main.swift -o swift_app
// swiftc main.swift -framework Cocoa -o swift_app

import Foundation
import Cocoa

class NFView: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        //commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //commonInit()
    }

    override func insertText(_ insertString: Any) {
        let string: String = insertString as! String
        Swift.print("insertText called in NFView: \(string)", terminator: "\n")
    }

    override func keyDown(with theEvent: NSEvent) {
        self.interpretKeyEvents([theEvent])
    }

    override func awakeFromNib() {
        Swift.print("NFView awake from Nib", terminator: "\n")
    }
}


class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        print("WindowDelegate windowWillClose called", terminator: "\n")
        NSApplication.shared().terminate(0)
    }
}

// https://developer.apple.com/library/mac/documentation/Cocoa/Reference/ApplicationKit/Classes/NSWindowController_Class/


class WindowController: NSWindowController {
    var _nfView: NFView
    unowned var _window: NSWindow

    override init(window: NSWindow?) {
        _window = window!
        _nfView = NFView(frame: self._window.contentView!.frame)

        super.init(window: window)

        _window.contentView!.addSubview(self._nfView)
        _window.makeFirstResponder(self._nfView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ApplicationDelegate: NSObject, NSApplicationDelegate {
    var _nfView: NFView
    var _window: NSWindow

    init(window: NSWindow) {
        _window = window

        // add the applications view to the window
        _nfView = NFView(frame: self._window.contentView!.frame)
        _window.contentView!.addSubview(self._nfView)
        _window.makeFirstResponder(self._nfView)

        //
        // NOTE: if had been using a nib the following would occur
        //
        // - set file owners properties according to nib then call viewDidLoad on each view
        // - set view outlets here then call awakeFromNib on each view
    }

    func applicationDidFinishLaunching(_ notification: Notification) {

        let mask = (NSEventMask.keyDown)
        let _ : AnyObject! = NSEvent.addLocalMonitorForEvents(matching: mask, handler: { (event: (NSEvent!)) -> NSEvent in
            //
            // TODO: send event data to desired method based on type
            //
            print("local KeyDown: \(event.characters) (\(String(event.keyCode)))", terminator: "\n")
            return event
        }) as AnyObject!

        print("application did finish launching", terminator: "\n")


        //
        // TODO: insert code here to initialize your application here
        //
        NSApp.activate(ignoringOtherApps: true)
    }
}


//
// TODO: implement this like the ObjC example and use in place of default NSApplication
//
class Application: NSApplication {
    var shouldKeepRunning: Bool = false

    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func run() {
        shouldKeepRunning = true
 
        //
    }

    override func terminate(_ sender: Any?) {
        //
    }
}



func main() -> Int32 {
    for argument in CommandLine.arguments {
        switch argument {
        default:
            print("", terminator: "")
        }
    }


    let nsApp = NSApplication.shared()
    //let _ = NSApplication.sharedApplication()

    nsApp.setActivationPolicy(NSApplicationActivationPolicy.regular)


    let menuBar = NSMenu()
    let appMenuItem = NSMenuItem()

    menuBar.addItem(appMenuItem)
    nsApp.mainMenu = menuBar

    let appMenu = NSMenu()
    let appName = ProcessInfo.processInfo.processName

    let quitTitle = "Quit " + appName
    let quitMenuItem = NSMenuItem(title: quitTitle, action: #selector(nsApp.terminate(_:)), keyEquivalent: "q")


    appMenu.addItem(quitMenuItem)
    appMenuItem.submenu = appMenu

    // window creation

    //let windowMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask

    let win = NSWindow(contentRect: NSMakeRect(100, 100, 600, 200), styleMask: NSTitledWindowMask,
        backing: NSBackingStoreType.buffered, defer: true)

    win.cascadeTopLeft(from: NSMakePoint(20, 20))
    win.title = appName
    win.makeKeyAndOrderFront(nil)


    // option #1 to get an app delegate reference
    //let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    //let aVariable = appDelegate.someVariable

    // option #2 to get an app delegate reference
    //if let del = NSApplication.sharedApplication().delegate as? AppDelegate {
    //    let moc = delegate.managedObjectContext
    //}


    let windowDelegate = WindowDelegate()
    win.delegate = windowDelegate

    let applicationDelegate = ApplicationDelegate(window: win)
    nsApp.delegate = applicationDelegate


    //
    // TODO: this needs to occur at the very end of the applicationDidFinishLaunching in
    //       order to correctly populate the menu bar and items
    //
    //nsApp.activateIgnoringOtherApps(true)


    nsApp.run()


    //
    // TODO: setup basic application to handle the main event loop
    //

    nsApp.terminate(nil)
    return 0
}

exit(main())
