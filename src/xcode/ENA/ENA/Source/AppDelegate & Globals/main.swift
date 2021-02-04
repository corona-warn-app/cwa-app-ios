////
// 🦠 Corona-Warn-App
//

import UIKit

private func delegateClassName() -> String? {
	if NSClassFromString("XCTestCase") != nil {
		// Need to call the initializer here to register a `BGTaskScheduler`
		_ = ENATaskScheduler.shared
		return nil
	}
	return NSStringFromClass(AppDelegate.self)
}

UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, delegateClassName())
