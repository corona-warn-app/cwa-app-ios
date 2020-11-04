import Foundation
import UIKit

final class ExposureSubmissionSuccessViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {

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

	// MARK: - UIViewController.

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTitle()
		setUpView()

		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionSuccess.button
	}

	private func setUpView() {
		navigationItem.hidesBackButton = true
		tableView.register(UINib(nibName: String(describing: ExposureSubmissionStepCell.self), bundle: nil), forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
		dynamicTableViewModel = .data
	}

	private func setupTitle() {
		title = AppStrings.ExposureSubmissionSuccess.title
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
	}
}

extension ExposureSubmissionSuccessViewController {
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		coordinator?.dismiss()
	}
}

private extension DynamicTableViewModel {
	static let data = DynamicTableViewModel([
		DynamicSection.section(
			header: .image(
				UIImage(named: "Illu_Submission_VielenDank"),
				accessibilityLabel: AppStrings.ExposureSubmissionSuccess.accImageDescription,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.accImageDescription
			),
			separators: .none,
			cells: [
				.body(text: AppStrings.ExposureSubmissionSuccess.description,
					  accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.description),
				.title2(text: AppStrings.ExposureSubmissionSuccess.listTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.listTitle),

				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItem1,
					icon: UIImage(named: "Icons - Hotline"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .normal
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionSuccess.listItem2,
					icon: UIImage(named: "Icons - Home"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .large
				),

				.title2(text: AppStrings.ExposureSubmissionSuccess.subTitle,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionSuccess.subTitle),

				.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_1, spacing: .large),
				.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_2, spacing: .large),
				.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_3, spacing: .large),
				.bulletPoint(text: AppStrings.ExposureSubmissionSuccess.listItem2_4, spacing: .large)
				
			]
		)
	])
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionSuccessViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
