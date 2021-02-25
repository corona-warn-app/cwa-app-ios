////
// 🦠 Corona-Warn-App
//

import UIKit

final class AccessibleTabbarController: UITabBarController {

	// MARK: - Init
	
	deinit {
		if let cancellableNotificationObserver = cancellableNotificationObserver {
			NotificationCenter.default.removeObserver(cancellableNotificationObserver)
		}
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		cancellableNotificationObserver = NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
			self?.setAttributes()
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setAttributes()
	}
	
	override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
		super.setViewControllers(viewControllers, animated: animated)
		setAttributes()
	}
	
	// MARK: - Private
	
	private var cancellableNotificationObserver: NSObjectProtocol?
	
	private func setAttributes() {
		let font = UIFont.systemFont(ofSize: UIFontMetrics.default.scaledValue(for: 10))
		tabBar.items?.forEach({ item in
			item.setTitleTextAttributes([.font: font], for: .normal)
		})
	}
}
