import UIKit

class ExposureSubmissionIntroViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Attributes.

	private(set) weak var coordinator: ExposureSubmissionCoordinating?

	// MARK: - Initializers.

	init?(coder: NSCoder, coordinator: ExposureSubmissionCoordinating) {
		super.init(coder: coder)
		self.coordinator = coordinator
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmission.continueText

		setupView()
		setupBackButton()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
		footerView?.secondaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.secondaryButton
	}

	// MARK: - Setup helpers.

	private func setupView() {
		setupTitle()
		setupTableView()
	}

	private func setupTitle() {
		navigationItem.largeTitleDisplayMode = .always
		title = AppStrings.ExposureSubmissionIntroduction.title
	}

	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
		dynamicTableViewModel = .intro
	}

	// MARK: - ENANavigationControllerWithFooterChild methods.

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		coordinator?.showOverviewScreen()
	}
}

private extension DynamicTableViewModel {
	static let intro = DynamicTableViewModel([
		.navigationSubtitle(text: AppStrings.ExposureSubmissionIntroduction.subTitle,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionIntroduction.subTitle),
		.section(
			header: .image(
				UIImage(named: "Illu_Submission_Funktion1"),
				accessibilityLabel: AppStrings.ExposureSubmissionIntroduction.accImageDescription,
				accessibilityIdentifier: AccessibilityIdentifiers.General.image,
				height: 200
			),
			separators: .none,
			cells: [
				.headline(text: AppStrings.ExposureSubmissionIntroduction.usage01,
						  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionIntroduction.usage01),
				.body(text: AppStrings.ExposureSubmissionIntroduction.usage02,
					  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionIntroduction.usage02),
				.bulletPoint(text: AppStrings.ExposureSubmissionIntroduction.listItem1, spacing: .large),
				.bulletPoint(text: AppStrings.ExposureSubmissionIntroduction.listItem2, spacing: .large),
				.bulletPoint(text: AppStrings.ExposureSubmissionIntroduction.listItem3, spacing: .large),
				.bulletPoint(text: AppStrings.ExposureSubmissionIntroduction.listItem4, spacing: .large)
			]
		)
	])
}

private extension ExposureSubmissionIntroViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
