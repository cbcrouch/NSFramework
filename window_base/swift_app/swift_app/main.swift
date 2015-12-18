//
//  main.swift
//  swift_app
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

// https://developer.apple.com/library/mac/documentation/Swift/Conceptual/Swift_Programming_Language/GuidedTour.html

import Foundation
import Cocoa


//
// values and strings
//

var myVariable = 42
myVariable = 50

let myConstant = 42

let implicitInt = 70
let implicitDouble = 70.0
let explicitDouble: Double = 70

let constFloat: Float = 4

let label = "The width is "
let width = 94
let widthLabel = label + String(width)

print(widthLabel)

let apples = 3
let oranges = 3
let appleSummary = "I have \(apples) apples."
let fruitSummary = "I have \(apples + oranges) pieces of fruit."

//
// arrays and dictionaries
//

var shoppingList = ["catfish", "water", "tulips", "blue paint"]
shoppingList[1] = "bottle of water"

var occupations = [
    "Malcolm": "Captain",
    "Kaylee": "Mechanic",
]
occupations["Jayne"] = "Public Relations"

let emptyArray = [String]()
let emptyDictionary = [String: Float]()

shoppingList = []  // empty array shorthand
occupations = [:]  // empty dicitionary shorthand

//
// control flow
//

let individualScores = [75, 43, 103, 87, 12]
var teamScore = 0
for score in individualScores {
    if score > 50 {
        teamScore += 3
    } else {
        teamScore += 1
    }
}
print("Team score is \(teamScore)")

var optionalName: String? = "John Appleseed"
//optionalName = nil

var greeting = "Hello!"
if let name = optionalName {
    greeting = "Hello, \(name)"
}
print(greeting)

let vegetable = "red pepper"
switch vegetable {
case "celery":
    let vegetableComment = "Add some raisins and make ants on a log."
case "cucumber", "watercress":
    let vegetableComment = "That would make a good tea sandwich"
case let x where x.hasSuffix("pepper"):
    let vegetableComment = "Is it spicy \(x)?"
default:
    let vegetableComment = "Everything tastes good in soup"
}

let interestingNumbers = [
    "Prime": [2, 3, 5, 7, 11, 13],
    "Fibonacci": [1, 1, 2, 3, 5, 8],
    "Square": [1, 4, 9, 16, 25],
]
var largest = 0
for (kind, numbers) in interestingNumbers {
    for number in numbers {
        if number > largest {
            largest = number
        }
    }
}
print("The largest interesting number is \(largest)")

var n = 2
while n < 100 {
    n = n * 2
}

var m = 2
repeat {
    m = m * 2
} while n < 100

var firstForLoop = 0
for i in 0..<4 {
    firstForLoop += i
}

var secondForLoop = 0
for var i = 0; i < 4; ++i {
    secondForLoop += i
}

//
// functions and closures
//

let customGreeting = greet("Bob", day: "Tuesday")
print("\(customGreeting)")

let statistics = calculateStstistics([5, 3, 100, 9])
print("sum is \(statistics.sum) and max is \(statistics.2)")

print("sum of () \(sumOf())")
print("sum of (42, 597, 12) \(sumOf(42, 597, 12))")

print("fifteen \(returnFifteen())")

var increment = makeIncrementer()
print("increment of 7: \(increment(7))")

var numbers = [20, 19, 7, 12]
print("numbers array has any matches: \(hasAnyMatches(numbers, condition: lessThanTen))")

//numbers.map({
//    (number: Int) -> Int in
//    let result = 3 * number
//    return result
//})
let mappedNumbers = numbers.map({ number in 3 * number })
print("mappedNumbers: \(mappedNumbers)")

let sortedNumbers = numbers.sort { $0 > $1 }
print("sortedNumbers: \(sortedNumbers)")

//
// objects and classes
//

var shape = Shape()
shape.numberOfSides = 7
var shapeDescription = shape.simpleDescription()
print(shapeDescription)

let test = Square(sideLength: 5.2, name: "my test square")
print("\(test.simpleDescription()) has an area of \(test.area())")

var triangle = EquilateralTriangle(sideLength: 3.3, name: "a triangle")
print("triangle's current perimeter = \(triangle.perimeter)")
triangle.perimeter = 9.9
print("triangle of perimeter \(triangle.perimeter) has a side length of \(triangle.sideLength)")

var triangleAndSquare = TriangleAndSquare(size: 10, name: "another test shape")
print("square side length: \(triangleAndSquare.square.sideLength)")
print("triangle side length: \(triangleAndSquare.triangle.sideLength)")
triangleAndSquare.square = Square(sideLength: 50, name: "largerSquare")
print("triangle side length: \(triangleAndSquare.triangle.sideLength)")

class Counter {
    var count: Int = 0
    // NOTE: specified a new name "times" for parameter "numberOfTimes"
    func incrementBy(amount: Int, numberOfTimes times: Int) {
        count += amount * times
    }
}
var counter = Counter()
counter.incrementBy(2, numberOfTimes: 7)

let optionalSquare: Square? = Square(sideLength: 2.5, name: "optional square")
let sideLength = optionalSquare?.sideLength
if sideLength != nil {
    print("optional side length: \(sideLength)")
}

//
// enumerations and structures
//

let ace = Rank.Ace
let aceRawValue = ace.rawValue
print("\(ace.simpleDescription())")
print("aceRawValue: \(aceRawValue)")

if let convertedRank = Rank(rawValue: 3) {
    let threeDescription = convertedRank.simpleDescription()
}

let hearts = Suit.Hearts
let heartsDescription = hearts.simpleDescription()

let threeOfSpades = Card(rank: .Three, suit: .Spades)
let threeOfSpadesDescription = threeOfSpades.simpleDescription()

enum ServerResponse {
    case Result(String, String)
    case Error(String)
}

let sucess = ServerResponse.Result("6:00 am", "8:09 pm")
let failure = ServerResponse.Error("Out of cheese.")

switch sucess {
case let .Result(sunrise, sunset):
    let serverResponse = "Sunrise is at \(sunrise) and sunset is at \(sunset)."
case let .Error(error):
    let serverResponse = "Failure... \(error)"
}

//
// protocols and extensions
//

protocol ExampleProtocol {
    var simpleDescription: String { get }
    mutating func adjust()
}

class SimpleClass: ExampleProtocol {
    var simpleDescription: String = "A very simple class."
    var anotherProperty: Int = 69105
    func adjust() {
        simpleDescription += " Now 100% adjusted."
    }
}
var a = SimpleClass()
a.adjust()
let aDescription = a.simpleDescription

struct SimpleStructure : ExampleProtocol {
    var simpleDescription: String = "A simple structure"
    mutating func adjust() {
        simpleDescription += " (adjusted)"
    }
}
var b = SimpleStructure()
b.adjust()
let bDescription = b.simpleDescription

enum SimpleEnum : ExampleProtocol {
    case Base, Adjusted

    var simpleDescription: String {
        get {
            switch self {
            case .Base:
                return "A simple enum"
            case .Adjusted:
                return "A simple enum [adjusted]"
            }
        }
    }

    mutating func adjust() {
        self = SimpleEnum.Adjusted
    }
}
var c = SimpleEnum.Base
c.adjust()
let cDescription = c.simpleDescription

extension Int: ExampleProtocol {
    var simpleDescription: String {
        return "The number \(self)"
    }
    mutating func adjust() {
        self += 42
    }
}
7.simpleDescription

let protocolValue: ExampleProtocol = a
print("protocolValue.simpleDescription: \(protocolValue.simpleDescription)")

//
// generics
//

func `repeat`<Item>(item: Item, times: Int) -> [Item] {
    var result = [Item]()
    for _ in 0..<times {
        result.append(item)
    }
    return result
}
`repeat`("knock", times: 4)

// reimplementation of the Swift standard library's optional type
enum OptionalValue<T> {
    case None
    case Some(T)
}
var possibleInteger: OptionalValue<Int> = .None
possibleInteger = .Some(100)

// use where after the type name to specify a list of requirements e.g. to require
// the type to implement a protocol, to require two types to be the same, or to
// require a class to have a particular superclass
func anyCommonElements <T, U where T: SequenceType, U: SequenceType,
    T.Generator.Element: Equatable, T.Generator.Element == U.Generator.Element>
    (lhs: T, rhs: U) -> Bool {
        // in the simple cases you can omit where and simply write the protcol or class
        // name after a color i.e. <T: Equatable> is the same as <T where T: Equatable>

        for lhsItem in lhs {
            for rhsItem in rhs {
                if lhsItem == rhsItem {
                    return true
                }
            }
        }
        return false
}
anyCommonElements([1,2,3], rhs: [3])

// modify the anyCommonElements function to make a function that returns an array of
// elements that any two sequences have in common




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
        Swift.print("insertText called in NFView")

        let string: String = insertString as! String
        Swift.print("\(string)")
    }

    override func keyDown(theEvent: NSEvent) {
        self.interpretKeyEvents([theEvent])
    }

    override func awakeFromNib() {
        Swift.print("NFView awake from Nib")
    }
}

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(notification: NSNotification) {
        print("WindowDelegate windowWillClose called")
        NSApplication.sharedApplication().terminate(0)
    }
}


class ApplicationDelegate: NSObject, NSApplicationDelegate {
    var _nfView: NFView
    var _window: NSWindow

    private func acquirePrivileges() -> Bool {
        let accessEnabled = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true])

        if accessEnabled != true {
            print("application does not have sufficient privileges to aquire global monitor for events")
        }
        return accessEnabled == true
    }

    private func handlerGlobalEvent(aEvent: (NSEvent!)) -> Void {
        print("global KeyDown: \(aEvent.characters) (\(String(aEvent.keyCode)))")
    }

    private func handlerEvent(aEvent: (NSEvent!)) -> NSEvent {
        print("local KeyDown: \(aEvent.characters) (\(String(aEvent.keyCode)))")
        return aEvent
    }

    private func listenForEvents() {
        let mask = (NSEventMask.KeyDownMask)

        //
        // NOTE: this is setup only to listen for key down events
        //
        //let _: AnyObject! = NSEvent.addGlobalMonitorForEventsMatchingMask(mask, handler: handlerGlobalEvent)
        let _: AnyObject! = NSEvent.addLocalMonitorForEventsMatchingMask(mask, handler: handlerEvent)
    }

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
        // TODO: try getting this working with a local event monitor as to not require elevated privileges
        //
        //acquirePrivileges()
        listenForEvents()

        //
        // TODO: look into manually creating/extending NSResponder to get a better idea of how events are
        //       handled for the view and/or make it work with multiple view, also note that setting the
        //       first responder will avoid system beeps for key events
        //
        self._window.makeFirstResponder(self._nfView)
        //self._window.makeFirstResponder(nil) // <-- will make the window the first responder

        print("application did finish launching")
    }
}


func main() -> Int32 {
    for argument in Process.arguments {
        switch argument {
        default:
            print("")
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
    // TODO: use application.run or NSRunLoop there is too much other stuff going on main event loop
    //       to tackle right away but would be nice to get a minimally working example
    //

/*
    var exitEventLoop = false
    while !exitEventLoop {

        autoreleasepool {
            let eventMask : Int = Int.init(truncatingBitPattern: NSEventMask.AnyEventMask.rawValue)

            // NOTE: need to use NSDate.distantFuture() for untilData param (can't pass in nil like in objc)
            let event = nsApp.nextEventMatchingMask(eventMask, untilDate: NSDate.distantFuture(),
                inMode: NSDefaultRunLoopMode, dequeue: true)!

            if event.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
                switch event.keyCode {
                case UInt16("q")!:
                    print("q pressed, will exit event loop")
                    exitEventLoop = true
                    break;

                default:
                    NSApp.sendEvent(event)
                }
            }
        }
    }
*/

    nsApp.terminate(nil)
    return 0
}

exit(main())
