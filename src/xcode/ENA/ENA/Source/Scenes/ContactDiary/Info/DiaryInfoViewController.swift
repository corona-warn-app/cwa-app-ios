//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DiaryInfoViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Init
	
	init(
		onPrimaryButtonTap: @escaping () -> Void
	) {
		self.onPrimaryButtonTap = onPrimaryButtonTap

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()

		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
		footerView?.secondaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.secondaryButton
		footerView?.isHidden = false
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		onPrimaryButtonTap()
	}

	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legal = "DynamicLegalCell"
	}

	// MARK: - Private

	private let viewModel = DiaryInfoViewModel()
	private let onPrimaryButtonTap: () -> Void

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.ExposureSubmissionQRInfo.primaryButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		item.title = AppStrings.ExposureSubmissionQRInfo.title

		return item
	}()

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legal.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
