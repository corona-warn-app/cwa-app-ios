#  SwiftUI Documentation

## Apple
Documentation of SwiftUI: https://developer.apple.com/documentation/swiftui

Tutorials: https://developer.apple.com/tutorials/swiftui/

## WWWDC 2019 Videos

Summary of WWDC 2019 Lectures: https://github.com/Blackjacx/WWDC

### Introducing SwiftUI
https://developer.apple.com/videos/play/wwdc2019/204

22:30 Data Flow Primitives: Constants, Property, @State, @Binding

30:30 Demo (continued)

### SwiftUI Essentials
https://developer.apple.com/videos/play/wwdc2019/216/

Interesting sections (Time mm:ss):

* 04:00 Views and Modifiers
* 12:00 Bindings
* 17:25 Importance of the order of modifiers
* 18:30 Prefer smaller, single-purpose views
* 19:35 Custom views
* 20:35 A view defines a piece of the UI
* 23:50 primitive views (Text, Color, Spacer, Image, Shape, Divider); see video "Building Custom Views in SwiftUI"
* 25:05 Views are defined declaratively as a function of their inputs
* 29:10 try to push your conditions into your modifiers as much as possible.
* 30:24 break down the code into smaller pieces
* 31:29 ForEach loop
* 33:47 Form { }
* 36:15 Button
* 38:00 Toggle
* 40:11 accessibility(label:)
* 41:46 Picker
* 44:05 Picker in a FORM
* 46:08 ContextMenu
* 47:44 Modifiers and Controls
* 49:09 Environment
* 50:22 Preview: effect of environment on the layout
* 51:55 Navigating your App

### Data Flow Through SwiftUI
Principles of Data Flow
* 04:00 Single Source of Truth
* 09:40 Every @State is a source of truth. 
Views are a function of state, not a sequence of events.
* 12:50 @State vs. @Binding: read and write w/out ownership; derivable from @State
* 13:50 $-prefix is a feture of property wrapper; see session "Modern Swift API Design"
* 15:30 TextField, Toggle, Slider – all expect a Binding as parameter
* 17:00 Button with animation
* 18:00 Working with External Data
* 19:45 Combine Publisher (main thread, .onReceive)
* 22:00 BindableObject Protocol (new: ObservableObject)
* 24:30 Creating Dependencies on BindableObject (@ObjectBinding)
* 26:50 Creating Dependencies Indirectly; put the model into the environment so it can be used everywhere in the app
* 28:52 When would I use EnvironmentObject vs. ObjectBinding?
* 29:36 Environment: Data applicable to an entire hierarchy – Convenience for indirection – Accent color, right-to-left, and more
* 30:30 Sources of Truth: @State and @BindableObject (for external data, the model)
* 31:40 Building Reusable Components
    * Read-only: Swift property, Environment
    * Read-write: @Binding
    * Prefer immutable access
* 32:45 @Binding
    * first class reference to data
    * great for reusability
    * use $ to derive from source
* 34:25 Using State Effectively
    * Limit use if possible
    * Use derived @Binding or value
    * Prefer BindableObject for persistence
    * Example: Button highlighting
* 36:20 Next Steps
    * Minimize sources of truth
    * Understand your data
    * Build a great app!
Anatomy of an Update
Understanding Your Data

More session:
* "What's New in Swift"
* "Modern Swift API Design"


### Building Custom Views in SwiftUI


### Introducing Combine
Combine is a unified declarative framework for processing values over time. Learn how it can simplify asynchronous code like networking, key value observing, notifications and callbacks.
* asynchronous processing
* 03:30 Publisher (value type, struct)
* 04:55 Subscriber (reference type; class)
* 06:10 The Pattern
* 06:50 Example
* 08:00 Operators (adopts Publisher; struct)
* 09:30 Operator Construction
* 11:00 Declarative Operator API
    * Functional transformations
    * List operations
    * Error handling
    * Thread or queue movement
    * Scheduling over time
* 11:35 Core design principle of Combine: Try composition first
* 12:00 Synchronous/async, single value/many values
* 14:45 async. processing – Zip: converts several inputs into a single tuple (when/AND): 
Example: enable a button when three conditions are true
* Combine Latest – converts several inputs into a single tuple (when/OR)

Web: https://www.avanderlee.com/swift/combine/

### Combine in Practice
* 22.30 Integrating Combine
* 23:55 use Interface Builder to create a target action: @IBAction func valueChanged(_ sender: UITextField)




### Integrating SwiftUI

### Accessibility in SwiftUI

### SwiftUI on all Devices


## WWDC 2020

### What's New in Swift
https://github.com/Blackjacx/WWDC#Whats-new-in-Swift

### What's New in SwiftUI
https://github.com/Blackjacx/WWDC#Whats-new-in-SwiftUI
09:00 Lists and Collections

### Stacks, Grids, and Outlines in SwiftUI
https://developer.apple.com/videos/play/wwdc2020/10031/ 


## LazyGrid
https://www.appcoda.com/swiftui-lazyvgrid-lazyhgrid/


## Swift with Majid
Property wrappers in SwiftUI
https://swiftwithmajid.com/2019/06/12/understanding-property-wrappers-in-swiftui/

### SwiftUI Cheat Sheet:
https://fuckingswiftui.com/
https://goshdarnswiftui.com/


Swift 5.1 references for busy coders
https://swiftly.dev

Hacking with Swift
https://www.hackingwithswift.com/articles

SWIFTUI and  Storyboard:
https://www.raywenderlich.com/3715234-swiftui-getting-started

A deeper understanding of SwiftUI
https://www.egeniq.com/blog/deeper-understanding-swiftui


## Apple Human Interface Guidelines – Gestures
https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/gestures/


## SwiftUI Environment Variables
A collection of environment values. Examples:
* colorScheme
* presentationMode
* timeZone
* verticalSizeClass

https://developer.apple.com/documentation/swiftui/environmentvalues

## Hacking Swift
What’s the difference between @ObservedObject, @State, and @EnvironmentObject?

https://www.hackingwithswift.com/quick-start/swiftui/whats-the-difference-between-observedobject-state-and-environmentobject
