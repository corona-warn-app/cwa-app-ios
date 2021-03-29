//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class TestResultAvailableViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

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
		
		parent?.navigationItem.hidesBackButton = true
		parent?.navigationItem.title = AppStrings.ExposureSubmissionTestResultAvailable.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton

		setupTableView()
		setupViewModel()
	}

	// MARK: - Protocol FooterViewUpdating

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		viewModel.onPrimaryButtonTap { [weak self] isLoading in
			self?.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
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
		viewModel.$isLoading.sink { [weak self] isLoading in
			self?.footerView?.setLoadingIndicator(false, disable: isLoading, button: .primary)
		}.store(in: &bindings)
	}

}
