import Foundation
import UIKit

class ExposureSubmissionWarnOthersViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
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

	// MARK: - Private

	private let viewModel: ExposureSubmissionWarnOthersViewModel
	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmissionWarnOthers.title
		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionWarnOthers.continueButton

		setupTableView()
	}

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionWarnOthersViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}

// MARK: - RequiresDismissConfirmation.

/// - NOTE: Marker protocol.
extension ExposureSubmissionWarnOthersViewController: RequiresDismissConfirmation { }
