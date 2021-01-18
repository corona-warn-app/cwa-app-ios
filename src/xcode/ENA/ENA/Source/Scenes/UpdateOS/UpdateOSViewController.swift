////
// 🦠 Corona-Warn-App
//

import UIKit

class UpdateOSViewController: UIViewController {
	
	// MARK: - Overrides
	
	override func loadView() {
		self.view = UpdateOSView()
	}
	 
	override func viewDidLoad() {
		super.viewDidLoad()
		
		customView.imageView.image = viewModel.image
		customView.titleLabel.text = viewModel.title
		customView.textLabel.text = viewModel.text
	}

	// MARK: - Private

	private let viewModel = UpdateOSViewModel()
	private var customView: UpdateOSView {
		// swiftlint:disable:next force_cast
		return view as! UpdateOSView
	}
}
