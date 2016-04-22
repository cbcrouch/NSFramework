//
//  main.swift
//  swift_app
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//


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

    override func insertText(insertString: AnyObject) {
        let string: String = insertString as! String
        Swift.print("insertText called in NFView: \(string)", terminator: "\n")
    }

    override func keyDown(theEvent: NSEvent) {
        self.interpretKeyEvents([theEvent])
    }

    override func awakeFromNib() {
        Swift.print("NFView awake from Nib", terminator: "\n")
    }
}

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(notification: NSNotification) {
        print("WindowDelegate windowWillClose called", terminator: "\n")
        NSApplication.sharedApplication().terminate(0)
    }
}

class ApplicationDelegate: NSObject, NSApplicationDelegate {
    var _nfView: NFView
    var _window: NSWindow

    init(window: NSWindow) {
        self._window = window

        // add the applications view to the window
        self._nfView = NFView(frame: self._window.contentView!.frame)
        self._window.contentView!.addSubview(self._nfView)

        //
        // NOTE: if had been using a nib the following would occur
        //
        // - set file owners properties according to nib then call viewDidLoad on each view
        // - set view outlets here then call awakeFromNib on each view
    }

    func applicationDidFinishLaunching(notification: NSNotification) {

        //
        // TODO: monitor all events and determine which will need to be handled when manually
        //       handling the event loop
        //
        let mask = (NSEventMask.KeyDownMask)

        let _ : AnyObject! = NSEvent.addLocalMonitorForEventsMatchingMask(mask, handler: { (event: (NSEvent!)) -> NSEvent in
            //
            // TODO: send event data to desired method based on type
            //
            print("local KeyDown: \(event.characters) (\(String(event.keyCode)))", terminator: "\n")
            return event
        })

        self._window.makeFirstResponder(self._nfView)

        print("application did finish launching", terminator: "\n")
    }
}

/*
class Application: NSApplication {
    var shouldKeepRunning: Bool

    override init() {
        shouldKeepRunning = false
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func run() {
        //
    }

    override func terminate(sender: AnyObject?) {
        //
    }
}
*/


func main() -> Int32 {
    for argument in Process.arguments {
        switch argument {
        default:
            print("", terminator: "")
        }
    }


    let nsApp = NSApplication.sharedApplication()
    //let _ = NSApplication.sharedApplication()

    nsApp.setActivationPolicy(NSApplicationActivationPolicy.Regular)


    let menuBar = NSMenu()
    let appMenuItem = NSMenuItem()

    menuBar.addItem(appMenuItem)
    nsApp.mainMenu = menuBar

    let appMenu = NSMenu()
    let appName = NSProcessInfo.processInfo().processName

    let quitTitle = "Quit " + appName
    let quitMenuItem = NSMenuItem(title: quitTitle, action: #selector(nsApp.terminate(_:)), keyEquivalent: "q")


    appMenu.addItem(quitMenuItem)
    appMenuItem.submenu = appMenu

    // window creation

    //let windowMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask

    let win = NSWindow(contentRect: NSMakeRect(100, 100, 600, 200), styleMask: NSTitledWindowMask,
        backing: NSBackingStoreType.Buffered, defer: true)

    win.cascadeTopLeftFromPoint(NSMakePoint(20, 20))
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

    nsApp.activateIgnoringOtherApps(true)


    nsApp.run()


    //
    // TODO: setup basic application to handle the main event loop
    //

    nsApp.terminate(nil)
    return 0
}

exit(main())
