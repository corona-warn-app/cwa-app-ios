////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInsTableViewController: UITableViewController {

	// MARK: - Init

	init() {
		checkInsViewModel = CheckInsViewModel()
		super.init(style: .grouped)
	}

	@available(*, unavailable)
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

	private let checkInsViewModel: CheckInsViewModel

}
