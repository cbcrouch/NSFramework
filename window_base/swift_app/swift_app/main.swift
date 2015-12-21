//
//  main.swift
//  swift_app
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

// https://developer.apple.com/library/mac/documentation/Swift/Conceptual/Swift_Programming_Language/GuidedTour.html

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
        Swift.print("insertText called in NFView", terminator: "\n")

        let string: String = insertString as! String
        Swift.print("\(string)", terminator: "\n")
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
        // TODO: can all this stuff be moved into the init method ?? (then what should be in this method ??)
        //

        // alternate way to setup keyboard listener
        let mask = (NSEventMask.KeyDownMask)
        let _ : AnyObject! = NSEvent.addLocalMonitorForEventsMatchingMask(mask, handler: { (event: (NSEvent!)) -> NSEvent in
            //
            // TODO: send event data to desired method based on type
            //
            print("local KeyDown: \(event.characters) (\(String(event.keyCode)))", terminator: "\n")
            return event
        })


        //
        // TODO: look into manually creating/extending NSResponder to get a better idea of how events are
        //       handled for the view and/or make it work with multiple view, also note that setting the
        //       first responder will avoid system beeps for key events
        //
        self._window.makeFirstResponder(self._nfView)
        //self._window.makeFirstResponder(nil) // <-- will make the window the first responder


        print("application did finish launching", terminator: "\n")
    }
}


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
    let quitMenuItem = NSMenuItem(title: quitTitle, action: Selector("terminate:"), keyEquivalent: "q")

    appMenu.addItem(quitMenuItem)
    appMenuItem.submenu = appMenu

    // window creation

    //let windowMask = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask

    let win = NSWindow(contentRect: NSMakeRect(100, 100, 600, 200), styleMask: NSTitledWindowMask,
        backing: NSBackingStoreType.Buffered, `defer`: true)

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


    //
    // TODO: decided what style to use and determine if can get menu bar to appear activated while
    //       setting ignore other apps to true
    //
    //NSApplication.sharedApplication().activateIgnoringOtherApps(true)
    //nsApp.activateIgnoringOtherApps(true)


    //
    // TODO: do these two calls ultimately result in running the same code ??
    //
    //NSRunLoop.mainRunLoop().run()
    nsApp.run()


    //
    // TODO: setup basic application to handle the main event loop
    //

    nsApp.terminate(nil)
    return 0
}

exit(main())
