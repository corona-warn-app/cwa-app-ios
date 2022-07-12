//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

final class FamilyMemberConsentViewModel {

	// MARK: - Init

	init(
		_ name: String? = nil,
		presentDisclaimer: @escaping () -> Void
	) {
		self.presentDisclaimer = presentDisclaimer
		self.isPrimaryButtonEnabled = false
		self.name = name
	}

	// MARK: - Internal

	let title = AppStrings.HealthCertificate.FamilyMemberConsent.title

	@OpenCombine.Published private(set) var isPrimaryButtonEnabled: Bool
	@OpenCombine.Published private(set) var name: String? {
		didSet {
			isPrimaryButtonEnabled = !(name?.isEmpty ?? true)
		}
	}

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			// Illustration with information text and text input cell
			.section(
				header:
						.image(
							UIImage(
								imageLiteralResourceName: "Illu_Family_Test_Consent"
							),
							accessibilityLabel: AppStrings.HealthCertificate.FamilyMemberConsent.imageDescription,
							accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.imageDescription,
							height: 220
						),
				cells: [
					.title2(text: AppStrings.HealthCertificate.FamilyMemberConsent.headline),
					.body(text: AppStrings.HealthCertificate.FamilyMemberConsent.inputTitle),
					.textInput(
						text: name,
						placeholder: AppStrings.HealthCertificate.FamilyMemberConsent.inputPlaceholder,
						configure: { [weak self] cell in
							guard let self = self else {
								fatalError("Failed to get strong self")
							}
							cell.$model
								.sink(
									receiveValue: { name in
										self.name = name
									}
								)
								.store(in: &self.subscriptions)
						}
					),
					.icon(UIImage(imageLiteralResourceName: "Icon_Family"), text: .string(AppStrings.HealthCertificate.FamilyMemberConsent.body01), alignment: .top),
					.icon(UIImage(imageLiteralResourceName: "Icons_Certificates_01"), text: .string(AppStrings.HealthCertificate.FamilyMemberConsent.body02), alignment: .top)
				]
			),
			// Legal text
			.section(
				cells: [
					.legalExtended(
						title: NSAttributedString(string: AppStrings.HealthCertificate.FamilyMemberConsent.Legal.headline),
						subheadline1: NSAttributedString(string: AppStrings.HealthCertificate.FamilyMemberConsent.Legal.subHeadline, attributes: normalTextAttribute),
						bulletPoints1: [
							bulletPointCellWithBoldHeadline(
								title: AppStrings.HealthCertificate.FamilyMemberConsent.Legal.bulletPoint,
								text: AppStrings.HealthCertificate.FamilyMemberConsent.Legal.text
							)
						],
						subheadline2: nil,
						accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.Legal.acknowledgementTitle,
						configure: { _, cell, _ in
							cell.backgroundColor = .enaColor(for: .background)
						}
					)
				]
			),
			// Disclaimer cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.ExposureSubmission.TestCertificate.Info.dataPrivacyTitle,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.dataPrivacyTitle,
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

	private let presentDisclaimer: () -> Void
	private var subscriptions = Set<AnyCancellable>()

	private let boldTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
	]
	private let normalTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body)
	]

	private func bulletPointCellWithBoldHeadline(title: String, text: String) -> NSMutableAttributedString {
		let bulletPoint = NSMutableAttributedString(string: "\(title)" + "\n\t", attributes: boldTextAttribute)
		bulletPoint.append(NSAttributedString(string: text, attributes: normalTextAttribute))
		return bulletPoint
	}

}

private extension DynamicCell {

	static func textInput(
		text: String? = nil,
		placeholder: String? = nil,
		configure: @escaping (FamilyNameTextFieldCell) -> Void
	) -> Self {
		let identifier = DynamicTableViewCellReuseIdentifier(
			rawValue: FamilyNameTextFieldCell.reuseIdentifier
		)
		let dynamicCell = DynamicCell.identifier(
			identifier,
			configure: { _, cell, _ in
				guard let cell = cell as? FamilyNameTextFieldCell else {
					fatalError("Failed to get FamilyNameTextFieldCell")
				}
				cell.configure(text: text, placeholder: placeholder)
				configure(cell)
			}
		)
		return dynamicCell
	}

}
