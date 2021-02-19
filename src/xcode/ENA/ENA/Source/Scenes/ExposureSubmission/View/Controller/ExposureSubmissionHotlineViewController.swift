//
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionHotlineViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		onSecondaryButtonTap: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.onSecondaryButtonTap = onSecondaryButtonTap

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

		view.backgroundColor = .enaColor(for: .background)
		title = AppStrings.ExposureSubmissionHotline.title

		setupTableView()
		setupBackButton()
		
		footerView?.primaryButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionHotline.primaryButton
		footerView?.secondaryButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionHotline.secondaryButton
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		footerView?.isHidden = false
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		callHotline()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		self.onSecondaryButtonTap()
	}

	// MARK: - Private
	
	private let onSecondaryButtonTap: () -> Void

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		item.primaryButtonTitle = AppStrings.ExposureSubmissionHotline.callButtonTitle
		item.isPrimaryButtonEnabled = true
		item.secondaryButtonTitle = AppStrings.ExposureSubmissionHotline.tanInputButtonTitle
		item.isSecondaryButtonEnabled = true
		item.isSecondaryButtonHidden = false
		item.title = AppStrings.ExposureSubmissionHotline.title
		return item
	}()

	private func setupTableView() {
		tableView.separatorStyle = .none

		tableView.register(ExposureSubmissionStepCell.self, forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)

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

	private func callHotline() {
		guard let url = URL(string: "telprompt:\(AppStrings.ExposureSubmission.hotlineNumber)"),
			  UIApplication.shared.canOpenURL(url) else {
			Log.error("Call failed: telprompt:\(AppStrings.ExposureSubmission.hotlineNumber) failed")
			return
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionHotlineViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
