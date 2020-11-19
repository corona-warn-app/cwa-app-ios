//
// 🦠 Corona-Warn-App
//

import Foundation

final class TestresultAvailableViewController: DynamicTableViewController {

	// MARK: - Init

	init(_ viewModel: TestresultAvailableViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: TestresultAvailableViewModel

}
