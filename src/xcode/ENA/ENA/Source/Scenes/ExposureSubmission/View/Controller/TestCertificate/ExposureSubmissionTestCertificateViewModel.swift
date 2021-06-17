////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestCertificateViewModel {

	// MARK: - Init

	init(
		testType: CoronaTestType,
		presentDisclaimer: @escaping () -> Void
	) {
		self.presentDisclaimer = presentDisclaimer
		self.testType = testType
		self.isPrimaryButtonEnabled = testType == .antigen
	}

	// MARK: - Internal

	private(set) var dateOfBirth: Date? {
		didSet {
			isPrimaryButtonEnabled = dateOfBirth != nil
		}
	}

	@OpenCombine.Published private(set) var isPrimaryButtonEnabled: Bool

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
		case birthdayDatePicker = "BirthdayDatePickerCell"
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			// Illustration with information text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Test_Certificate"
						),
						accessibilityLabel: AppStrings.ExposureSubmission.TestCertificate.Info.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.imageDescription,
						height: 161
					),
				cells: [
					.body(
						text: AppStrings.ExposureSubmission.TestCertificate.Info.body,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.body
					),
					testType == .antigen ? nil : .birthdayDatePicker(
						placeholder: AppStrings.ExposureSubmission.TestCertificate.Info.birthdayPlaceholder,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.birthdayPlaceholder,
						configure: { [weak self] _, cell, _ in
							guard let birthdayDateInputCell = cell as? BirthdayDatePickerCell,
								  let self = self else {
								return
							}
							self.subscriptions.forEach { $0.cancel() }
							birthdayDateInputCell.$dateOfBirth
								.dropFirst()
								.assign(to: \.dateOfBirth, on: self)
								.store(in: &self.subscriptions)
							birthdayDateInputCell.dateOfBirth = self.dateOfBirth
						}
					),
					testType == .antigen ? nil : .body(
						text: AppStrings.ExposureSubmission.TestCertificate.Info.birthdayText,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.birthdayText
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Certificates_01"),
						text: .string(AppStrings.ExposureSubmission.TestCertificate.Info.section_1),
						alignment: .top
					),
					.space(
						height: 15.0,
						color: .enaColor(for: .background)
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Certificates_02"),
						text: .string(AppStrings.ExposureSubmission.TestCertificate.Info.section_2),
						alignment: .top
					)
				].compactMap { $0 }
			),
			// Legal text
			.section(cells: [
				.legalExtended(
					title: NSAttributedString(string: AppStrings.ExposureSubmission.TestCertificate.Info.legalHeadline_1),
					subheadline1: nil,
					bulletPoints1: [
						NSAttributedString(string: AppStrings.ExposureSubmission.TestCertificate.Info.legalText_1),
						NSAttributedString(string: AppStrings.ExposureSubmission.TestCertificate.Info.legalText_2),
						NSAttributedString(string: AppStrings.ExposureSubmission.TestCertificate.Info.legalText_3),
						NSAttributedString(string: AppStrings.ExposureSubmission.TestCertificate.Info.legalText_4),
						NSAttributedString(string: AppStrings.ExposureSubmission.TestCertificate.Info.legalText_5)
					],
					subheadline2: nil,
					accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.acknowledgementTitle,
					configure: { _, cell, _ in
						cell.backgroundColor = .enaColor(for: .background)
					}
				)
			]),
			// Disclaimer cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.ExposureSubmission.TestCertificate.Info.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmission.TestCertificate.Info.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { [weak self] _, _ in
							self?.presentDisclaimer()
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						})
				]
			)
		])
	}

	// MARK: - Private

	private let testType: CoronaTestType
	private let presentDisclaimer: () -> Void

	private var subscriptions = Set<AnyCancellable>()

}
