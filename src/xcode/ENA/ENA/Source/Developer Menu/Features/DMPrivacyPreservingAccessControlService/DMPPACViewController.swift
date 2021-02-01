////
// 🦠 Corona-Warn-App
//

import UIKit

class DMPPACViewController: UITableViewController {

	// MARK: - Init

	init( _ store: Store, deviceCheck: DeviceCheckable) {
		self.viewModel = DMPPCViewModel(store, deviceCheck: deviceCheck)
		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			super.init(style: .grouped)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: DMPPCViewModel

}
