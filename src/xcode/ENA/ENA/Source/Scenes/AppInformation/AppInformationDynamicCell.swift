//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

extension DynamicCell {
	static func phone(
		text: String,
		number: String,
		accessibilityIdentifier: String? = nil,
		foreign: Bool = false
	) -> Self {
		
		let image = foreign ? UIImage(named: "phone_foreign") : UIImage(named: "phone")
		var cell: DynamicCell = .icon(image, text: .string(text), tintColor: .enaColor(for: .textPrimary1), selectionStyle: .default, action: .call(number: number)) { _, cell, _ in
			cell.textLabel?.textColor = .enaColor(for: .textTint)
			(cell.textLabel as? ENALabel)?.style = .title2
			
			cell.isAccessibilityElement = true
			cell.accessibilityIdentifier = accessibilityIdentifier
			cell.accessibilityLabel = "\(AppStrings.AccessibilityLabel.phoneNumber):\n\n\(text)"
			cell.accessibilityTraits = .button
			
			cell.accessibilityCustomActions?.removeAll()

			if #available(iOS 13, *) {
				let actionName = "\(AppStrings.ExposureSubmissionHotline.callButtonTitle) \(AppStrings.AccessibilityLabel.phoneNumber)"
				cell.accessibilityCustomActions = [
					UIAccessibilityCustomAction(name: actionName, actionHandler: {  _ -> Bool in
						let phoneNumber = foreign ? AppStrings.ExposureSubmission.hotlineNumberForeign : AppStrings.ExposureSubmission.hotlineNumber
						LinkHelper.open(urlString: "telprompt:\(phoneNumber)")
						return true
					})
				]
			}
		}
		cell.tag = "phone"
		return cell
	}
	
	static func imprintHeadlineWithoutBottomInset(text: String, accessibilityIdentifier: String? = nil) -> Self {
		.headline(text: text, accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.bottom = 0
			cell.accessibilityIdentifier = accessibilityIdentifier
			cell.accessibilityTraits = .header
		}
	}
	
	static func bodyWithoutTopInset(text: String, style: TextCellStyle = .label, accessibilityIdentifier: String? = nil) -> Self {
		.body(text: text, style: style, accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.top = 0
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}
	
	/// Creates a cell that renders a view of a .html file with interactive texts, such as mail links, phone numbers, and web addresses.
	static func html(url: URL) -> Self {
		.identifier(AppInformationDetailViewController.CellReuseIdentifier.html) { _, cell, _  in
			guard let cell = cell as? DynamicTableViewHtmlCell else { return }
			cell.webView.load(URLRequest(url: url))
		}
	}
}
