//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionQRInfoViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Init
	
	init(
		supportedCountries: [Country],
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = ExposureSubmissionQRInfoViewModel(supportedCountries: supportedCountries)
		self.onPrimaryButtonTap = onPrimaryButtonTap

		super.init(nibName: nil, bundle: nil)
		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
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
		onPrimaryButtonTap { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonLoading = isLoading
				self?.navigationFooterItem?.isPrimaryButtonEnabled = !isLoading
			}
		}
	}

	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legal = "DynamicLegalCell"
		case countries = "LabeledCountriesCell"
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionQRInfoViewModel
	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void

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

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legal.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: LabeledCountriesCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.countries.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
