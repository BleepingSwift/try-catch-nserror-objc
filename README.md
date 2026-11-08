# TryCatchNserrorObjc

Sample Objective-C code demonstrating Objective-C has @try and @catch, but the community settled on NSError. Measured on Xcode 27.1: what exceptions leak, what they cost, and how to use NSError well..

> This project accompanies the article: [Why Objective-C Has try-catch But Nobody Uses It](https://bleepingswift.com/blog/try-catch-nserror-objc)

## Requirements

- Xcode 27.1+
- iOS 26.0+

## Getting Started

1. Clone this repository
2. Run `xcodegen generate` (requires [XcodeGen](https://github.com/yonaskolb/XcodeGen))
3. Open `TryCatchNserrorObjc.xcodeproj`
4. Build and run

## What's Included

- **main.m**: Source file
- **AppDelegate.h**: Source file
- **AppDelegate.m**: Source file
- **MyAppError.h**: Source file
- **MyAppError.m**: Source file
- **Tracker.h**: Source file
- **Tracker.m**: Source file
- **ErrorDemo.h**: Source file
- **ErrorDemo.m**: Source file
- **ViewController.h**: Source file
- **ViewController.m**: Source file

## Language

This project is written in **Objective-C** to demonstrate traditional iOS development patterns.

## Learn More

Read the full article at [BleepingSwift](https://bleepingswift.com/blog/try-catch-nserror-objc) for detailed explanations and additional examples.

## License

MIT License - see [LICENSE](LICENSE) for details.
