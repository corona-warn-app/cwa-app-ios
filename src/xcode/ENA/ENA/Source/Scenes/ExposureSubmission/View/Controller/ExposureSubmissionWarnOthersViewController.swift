//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionWarnOthersViewController: DynamicTableViewController {
	
	// MARK: - Init

	init?(
		coder: NSCoder,
		supportedCountries: [Country],
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void
	) {
		self.viewModel = ExposureSubmissionWarnOthersViewModel(supportedCountries: supportedCountries)
		self.onPrimaryButtonTap = onPrimaryButtonTap

		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
		footerView?.isHidden = false
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case acknowledgement = "DynamicAcknowledgementCell"
		case countries = "LabeledCountriesCell"
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionWarnOthersViewModel
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
		cellBackgroundColor = .clear

		tableView.register(
			UINib(nibName: String(describing: DynamicAcknowledgementCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.acknowledgement.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: LabeledCountriesCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.countries.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionWarnOthersViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}

// MARK: - Protocol ENANavigationControllerWithFooterChild
extension ExposureSubmissionWarnOthersViewController: ENANavigationControllerWithFooterChild {

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		onPrimaryButtonTap { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonLoading = isLoading
				self?.navigationFooterItem?.isPrimaryButtonEnabled = !isLoading
			}
		}
	}
}

// MARK: - RequiresDismissConfirmation.

/// - NOTE: Marker protocol.
extension ExposureSubmissionWarnOthersViewController: RequiresDismissConfirmation { }
