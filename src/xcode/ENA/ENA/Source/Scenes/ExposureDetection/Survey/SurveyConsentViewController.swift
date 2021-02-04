////
// 🦠 Corona-Warn-App
//

import UIKit

final class SurveyConsentViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: SurveyConsentViewModel,
		onStartSurveyTap: @escaping (URL) -> Void
	) {
		self.viewModel = viewModel
		self.onStartSurveyTap = onStartSurveyTap

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
		guard let url = URL(string: "https://www.test.de") else {
			return
		}
		onStartSurveyTap(url)
	}

	// MARK: - Public

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

		navigationFooterItem?.isPrimaryButtonLoading = true
	}

	// MARK: - Private

	private let onStartSurveyTap: (URL) -> Void
	private let viewModel: SurveyConsentViewModel
}
