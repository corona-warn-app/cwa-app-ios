//
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionHotlineViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Attributes.

	private(set) weak var coordinator: ExposureSubmissionCoordinating?

	// MARK: - Initializers.

	init?(coder: NSCoder, coordinator: ExposureSubmissionCoordinating) {
		self.coordinator = coordinator
		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View lifecycle methods.

	override func viewDidLoad() {
		super.viewDidLoad()
		setUpView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupButtons()
		
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
	}

	// MARK: - View setup.

	private func setUpView() {
		title = AppStrings.ExposureSubmissionHotline.title
		setupButtons()
		setupTableView()
		setupBackButton()
	}

	private func setupButtons() {
		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionHotline.callButtonTitle
		navigationFooterItem?.secondaryButtonTitle = AppStrings.ExposureSubmissionHotline.tanInputButtonTitle
		navigationFooterItem?.isSecondaryButtonHidden = false
	}

	// MARK: - Data setup.

	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)

		dynamicTableViewModel = DynamicTableViewModel(
			[
				.section(
					header: .image(UIImage(named: "Illu_Submission_Kontakt"),
								   accessibilityLabel: AppStrings.ExposureSubmissionHotline.imageDescription,
								   accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.imageDescription),
					cells: [
						.body(text: [AppStrings.ExposureSubmissionHotline.description, AppStrings.Common.tessRelayDescription].joined(separator: "\n\n"),
							  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.description) { _, cell, _ in
								cell.textLabel?.accessibilityTraits = .header
						}
					]
				),
				DynamicSection.section(
					cells: [
						.title2(text: AppStrings.ExposureSubmissionHotline.sectionTitle,
								accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.sectionTitle),
						ExposureSubmissionDynamicCell.stepCell(
							style: .body,
							title: AppStrings.ExposureSubmissionHotline.sectionDescription1,
							icon: UIImage(named: "Icons_Grey_1"),
							iconAccessibilityLabel: AppStrings.ExposureSubmissionHotline.iconAccessibilityLabel1 + " " + AppStrings.ExposureSubmissionHotline.sectionDescription1,
							hairline: .iconAttached,
							bottomSpacing: .normal
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .headline,
							color: .enaColor(for: .textTint),
							title: AppStrings.ExposureSubmissionHotline.phoneNumber,
							accessibilityLabel: AppStrings.ExposureSubmissionHotline.callButtonTitle,
							accessibilityTraits: [.button],
							hairline: .topAttached,
							bottomSpacing: .normal,
							action: .execute { [weak self] _, _ in self?.callHotline() }
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .footnote,
							title: AppStrings.ExposureSubmissionHotline.hotlineDetailDescription,
							accessibilityLabel: AppStrings.ExposureSubmissionHotline.hotlineDetailDescription,
							hairline: .topAttached,
							bottomSpacing: .large
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .body,
							title: AppStrings.ExposureSubmissionHotline.sectionDescription2,
							icon: UIImage(named: "Icons_Grey_2"),
							iconAccessibilityLabel: AppStrings.ExposureSubmissionHotline.iconAccessibilityLabel2 + " " + AppStrings.ExposureSubmissionHotline.sectionDescription2,
							hairline: .none
						)
					])
			]
		)
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionHotlineViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}

// MARK: - ENANavigationControllerWithFooterChild Extension.

extension ExposureSubmissionHotlineViewController {
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		callHotline()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		self.coordinator?.showTanScreen()
	}

	private func callHotline() {
		if let url = URL(string: "telprompt:\(AppStrings.ExposureSubmission.hotlineNumber)") {
			if UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
}
