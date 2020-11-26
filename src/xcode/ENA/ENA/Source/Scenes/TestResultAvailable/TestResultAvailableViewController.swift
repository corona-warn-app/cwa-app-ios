//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import Combine

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
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.didTapPrimaryFooterButton()
	}

	// MARK: Protocol DismissHandling
	/// called on close button & swip down dismiss
	func presentDismiss(dismiss: @escaping () -> Void) {
		viewModel.presentDismissAlert()
	}

	// MARK: - Private

	private let viewModel: TestResultAvailableViewModel
	private var bindings: Set<AnyCancellable> = []

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		item.primaryButtonTitle = AppStrings.ExposureSubmissionTestresultAvailable.primaryButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true
		item.title = AppStrings.ExposureSubmissionTestresultAvailable.title
		return item
	}()

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none
	}

	private func setupViewModel() {
		viewModel.dynamicTableviewModelPublisher.sink { [weak self] dynamicTableViewModel in
			guard let dynamicTableViewModel = dynamicTableViewModel,
				let self = self else {
				Log.debug("Faile to get dynamic tableview model - return early")
				return
			}
			self.dynamicTableViewModel = dynamicTableViewModel
			self.tableView?.reloadData()
		}.store(in: &bindings)
	}

}
