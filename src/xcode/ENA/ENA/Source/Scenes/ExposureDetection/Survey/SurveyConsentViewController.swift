////
// 🦠 Corona-Warn-App
//

import UIKit

final class SurveyConsentViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: SurveyConsentViewModel,
		completion: @escaping (URL) -> Void
	) {
		self.viewModel = viewModel
		self.completion = completion

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

		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.SurveyConsent.acceptButton
		footerView?.isHidden = false
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		navigationFooterItem?.isPrimaryButtonLoading = true
		navigationFooterItem?.isPrimaryButtonEnabled = false

		viewModel.getURL { [weak self] result in
			switch result {
			case .success(let url):
				self?.completion(url)
			case .failure(let error):
				self?.showErrorAlert(with: error)
			}
			self?.navigationFooterItem?.isPrimaryButtonLoading = false
			self?.navigationFooterItem?.isPrimaryButtonEnabled = true
		}
	}

	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legal = "DynamicLegalCell"
	}

	// MARK: - Private

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.SurveyConsent.acceptButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		return item
	}()

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legal.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}

	private func showErrorAlert(with error: SurveyError) {
		let errorAlert = UIAlertController.errorAlert(
			title: AppStrings.SurveyConsent.errorTitle,
			message: error.description
		)
		present(errorAlert, animated: true)
	}

	// MARK: - Private

	private let completion: (URL) -> Void
	private let viewModel: SurveyConsentViewModel
}
