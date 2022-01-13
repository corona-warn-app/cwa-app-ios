//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct QRScannerInfoViewModel {
	
	init(
		onDataPrivacyTap: @escaping () -> Void
	) {
		self.onDataPrivacyTap = onDataPrivacyTap
	}
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				cells: [
					.headlineWithImage(
						headerText: AppStrings.UniversalQRScanner.Info.title,
						image: UIImage(imageLiteralResourceName: "Illu_QRScannerInfo"),
						imageAccessibilityIdentifier: AccessibilityIdentifiers.UniversalQRScanner.Info.title
					),
					.space(height: 24.0),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_QRScannerInfo_01"),
						text: .string(AppStrings.UniversalQRScanner.Info.bulletPoint1),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_QRScannerInfo_02"),
						text: .string(AppStrings.UniversalQRScanner.Info.bulletPoint2),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_QRScannerInfo_03"),
						text: .string(AppStrings.UniversalQRScanner.Info.bulletPoint3),
						alignment: .top
					),
					.icon(
						UIImage(imageLiteralResourceName: "Icons_QRScannerInfo_04"),
						text: .string(AppStrings.UniversalQRScanner.Info.bulletPoint4),
						alignment: .top
					),
					.space(height: 16.0),
					.body(
						text: AppStrings.UniversalQRScanner.Info.body1
					),
					.body(
						text: AppStrings.UniversalQRScanner.Info.body2
					),
					.space(height: 24.0)
				]
			),
			
			// Data privacy cell
			.section(
				separators: .all,
				cells: [
					.body(
						text: AppStrings.UniversalQRScanner.Info.dataPrivacy,
						style: DynamicCell.TextCellStyle.label,
						accessibilityIdentifier: AccessibilityIdentifiers.UniversalQRScanner.Info.dataPrivacy,
						accessibilityTraits: UIAccessibilityTraits.link,
						action: .execute { _, _ in
							onDataPrivacyTap()
						},
						configure: { _, cell, _ in
							cell.accessoryType = .disclosureIndicator
							cell.selectionStyle = .default
						}
					),
					.space(height: 36.0)
				]
			)
		])
	}
	
	// MARK: - Private

	private let onDataPrivacyTap: () -> Void
	
}
