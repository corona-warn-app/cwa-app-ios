////
// 🦠 Corona-Warn-App
//

import UIKit

class AppDisabledViewController: UIViewController {
	
	// MARK: - Overrides
	
	override func loadView() {
		self.view = AppDisabledView()
	}
	 
	override func viewDidLoad() {
		super.viewDidLoad()
		customView.textLabel.text = viewModel.text
	}

	// MARK: - Private

	private let viewModel = AppDisabledViewModel()
	private var customView: AppDisabledView {
		// swiftlint:disable:next force_cast
		return view as! AppDisabledView
	}
}
