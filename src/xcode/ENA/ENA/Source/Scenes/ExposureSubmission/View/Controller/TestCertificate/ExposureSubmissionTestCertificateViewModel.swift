////
// 🦠 Corona-Warn-App
//

import UIKit

struct ExposureSubmissionTestCertificateViewModel {

	// MARK: - Init

	init(
		presentDisclaimer: @escaping () -> Void
	) {
		self.presentDisclaimer = presentDisclaimer
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

//	let section01ImageName = "Icons_Certificates_01"
//	let section02ImageName = "Icons_Certificates_02"

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
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
				]
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
						text: AppStrings.ContactDiary.Information.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.ContactDiaryInformation.dataPrivacyTitle,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { _, _ in
							presentDisclaimer()
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

	private let presentDisclaimer: () -> Void

}
