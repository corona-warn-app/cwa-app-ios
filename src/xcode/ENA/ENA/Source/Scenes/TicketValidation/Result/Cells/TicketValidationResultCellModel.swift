//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit.UIImage
import OpenCombine
import HealthCertificateToolkit
import class CertLogic.ValidationResult

final class TicketValidationResultCellModel {

	// MARK: - Init

	init(
		validationResultItem: TicketValidationResult.ResultItem
	) {
		self.validationResultItem = validationResultItem
	}

	// MARK: - Internal

	var iconImage: UIImage? {
		switch validationResultItem.result {
		case .failed:
			return UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Failed")
		case .open:
			return UIImage(imageLiteralResourceName: "Icon_CertificateValidation_Open")
		case .passed:
			return nil
		}
	}

	var itemDetails: String? {
		validationResultItem.details
	}

	var keyValueAttributedString: NSAttributedString {
		NSAttributedString(
			attributedString: [
				keyFormatterAttributedString(key: "Regel-ID / Rule ID"),
				valueFormatterAttributedString(value: validationResultItem.identifier)
			].joined(with: "\n")
		)
	}

	// MARK: - Private

	private let validationResultItem: TicketValidationResult.ResultItem

	private func keyFormatterAttributedString(key: String) -> NSAttributedString {
		let spaceParagraphStyle = NSMutableParagraphStyle()
		spaceParagraphStyle.paragraphSpacingBefore = 16.0
		spaceParagraphStyle.lineHeightMultiple = 0.8
		return NSAttributedString(
			string: key,
			attributes: [
				.font: UIFont.enaFont(for: .footnote) ,
				.foregroundColor: UIColor.enaColor(for: .textPrimary2),
				.paragraphStyle: spaceParagraphStyle
			]
		)
	}

	private func valueFormatterAttributedString(value: String?) -> NSAttributedString {
		return NSAttributedString(
			string: value ?? "",
			attributes: [
				.font: UIFont.enaFont(for: .subheadline) ,
				.foregroundColor: UIColor.enaColor(for: .textPrimary1)
			]
		)
	}

}
