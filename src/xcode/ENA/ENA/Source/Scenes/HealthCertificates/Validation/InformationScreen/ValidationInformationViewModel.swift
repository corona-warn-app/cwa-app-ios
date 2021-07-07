////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct ValidationInformationViewModel {

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([

			// Illustration with information text and bullet icons with text
			.section(
				header:
					.image(
						UIImage(
							imageLiteralResourceName: "Illu_Europe_Card"
						),
						accessibilityLabel: AppStrings.HealthCertificate.Validation.Info.imageDescription,
						accessibilityIdentifier: AccessibilityIdentifiers.HealthCertificate.Validation.Info.imageDescription,
						height: 274.0
					),
				cells: [
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Car"),
						text: .string(AppStrings.HealthCertificate.Validation.Info.byCar),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_Plane"),
						text: .string(AppStrings.HealthCertificate.Validation.Info.byPlane),
						alignment: .top
					)
				]
			)
		])
	}

	// MARK: - Private

//	private let didTapDataPrivacy: () -> Void

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

	private func bulletPointCellWithNormalText(text: String) -> NSMutableAttributedString {
		return NSMutableAttributedString(string: "\(text)", attributes: normalTextAttribute)
	}


}
