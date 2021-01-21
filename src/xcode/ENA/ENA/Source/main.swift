////
// 🦠 Corona-Warn-App
//

import UIKit

private func delegateClassName() -> String? {
	if NSClassFromString("XCTestCase") != nil {
		return nil
	}
	return NSStringFromClass(AppDelegate.self)
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, delegateClassName())
