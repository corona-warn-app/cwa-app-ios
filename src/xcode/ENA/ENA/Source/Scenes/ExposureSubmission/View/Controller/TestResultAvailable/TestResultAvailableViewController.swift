//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class TestResultAvailableViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Init

	init(_ viewModel: TestResultAvailableViewModel) {
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
		setupViewModel()
	}

	override var navigationItem: UINavigationItem {
		viewModel.navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.onPrimaryButtonTap { [weak self] isLoading in
			self?.viewModel.navigationFooterItem.isPrimaryButtonEnabled = !isLoading
			self?.viewModel.navigationFooterItem.isPrimaryButtonLoading = isLoading
		}
	}

	// MARK: Protocol DismissHandling

	/// called on close button & swipe down dismiss
	func wasAttemptedToBeDismissed() {
		viewModel.onDismiss()
	}

	// MARK: - Private

	private let viewModel: TestResultAvailableViewModel
	private var bindings: Set<AnyCancellable> = []

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none
	}

	private func setupViewModel() {
		viewModel.$dynamicTableViewModel.sink { [weak self] dynamicTableViewModel in
			self?.dynamicTableViewModel = dynamicTableViewModel
			self?.tableView?.reloadData()
		}.store(in: &bindings)
	}

}
