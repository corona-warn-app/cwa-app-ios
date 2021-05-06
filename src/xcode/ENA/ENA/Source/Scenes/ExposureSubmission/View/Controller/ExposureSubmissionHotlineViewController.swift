//
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionHotlineViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		onPrimaryButtonTap: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
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

		view.backgroundColor = .enaColor(for: .background)
		title = AppStrings.ExposureSubmissionHotline.title

		setupTableView()
		setupBackButton()
		
		footerView?.primaryButton.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionHotline.primaryButton
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
		self.onPrimaryButtonTap()
	}

	// MARK: - Private
	
	private let onPrimaryButtonTap: () -> Void

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		item.primaryButtonTitle = AppStrings.ExposureSubmissionHotline.tanInputButtonTitle
		item.isPrimaryButtonEnabled = true
		item.secondaryButtonTitle = AppStrings.ExposureSubmissionHotline.tanInputButtonTitle
		item.isSecondaryButtonEnabled = false
		item.isSecondaryButtonHidden = true
		item.title = AppStrings.ExposureSubmissionHotline.title
		return item
	}()

	private func setupTableView() {
		tableView.separatorStyle = .none

		tableView.register(ExposureSubmissionStepCell.self, forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)

		dynamicTableViewModel = DynamicTableViewModel(
			[
				.section(
					header: .image(
						UIImage(named: "Illu_Submission_Kontakt"),
						accessibilityLabel: AppStrings.ExposureSubmissionHotline.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.imageDescription
					),
					cells: [
						.body(
							text: [AppStrings.ExposureSubmissionHotline.description, AppStrings.Common.tessRelayDescription].joined(separator: "\n\n"),
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.description
						) { _, cell, _ in
							cell.textLabel?.accessibilityTraits = .header
						}
					]
				),
				DynamicSection.section(
					cells: [
						.title2(
							text: AppStrings.ExposureSubmissionHotline.sectionTitle,
							accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionHotline.sectionTitle
						),
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
							title: AppStrings.ExposureSubmissionHotline.phoneNumberDomestic,
							accessibilityLabel: AppStrings.ExposureSubmissionHotline.callButtonTitle,
							accessibilityTraits: [.button],
							hairline: .topAttached,
							bottomSpacing: .small,
							action: .execute { [weak self] _, _ in self?.callHotline() }
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .footnote,
							title: AppStrings.ExposureSubmissionHotline.phoneDetailsDomestic,
							accessibilityLabel: AppStrings.ExposureSubmissionHotline.phoneDetailsDomestic,
							hairline: .topAttached,
							bottomSpacing: .normal
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .headline,
							color: .enaColor(for: .textTint),
							title: AppStrings.ExposureSubmissionHotline.phoneNumberForeign,
							accessibilityLabel: AppStrings.ExposureSubmissionHotline.callButtonTitle,
							accessibilityTraits: [.button],
							hairline: .topAttached,
							bottomSpacing: .small,
							action: .execute { [weak self] _, _ in self?.callHotline(foreign: true) }
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .footnote,
							title: AppStrings.ExposureSubmissionHotline.phoneDetailsForeign,
							accessibilityLabel: AppStrings.ExposureSubmissionHotline.phoneDetailsForeign,
							hairline: .topAttached,
							bottomSpacing: .normal
						),
						ExposureSubmissionDynamicCell.stepCell(
							style: .footnote,
							title: AppStrings.ExposureSubmissionHotline.hotlineDetailDescription,
							accessibilityLabel: AppStrings.ExposureSubmissionHotline.hotlineDetailDescription,
							hairline: .topAttached,
							bottomSpacing: .normal
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

	private func callHotline(foreign: Bool = false) {
		let phoneNumber = foreign ? AppStrings.ExposureSubmission.hotlineNumberForeign : AppStrings.ExposureSubmission.hotlineNumber
		guard let url = URL(string: "telprompt:\(phoneNumber)"),
			  UIApplication.shared.canOpenURL(url) else {
			Log.error("Call failed: telprompt:\(phoneNumber) failed")
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
