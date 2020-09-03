//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import UIKit

extension DynamicCell {
	static func phone(text: String, number: String, accessibilityIdentifier: String? = nil) -> Self {
		var cell: DynamicCell = .icon(UIImage(systemName: "phone"), text: text, tintColor: .enaColor(for: .textPrimary1), action: .call(number: number)) { _, cell, _ in
			cell.textLabel?.textColor = .enaColor(for: .textTint)
			(cell.textLabel as? ENALabel)?.style = .title2
			
			cell.isAccessibilityElement = true
			cell.accessibilityIdentifier = accessibilityIdentifier
			cell.accessibilityLabel = "\(AppStrings.AccessibilityLabel.phoneNumber):\n\n\(text)"
			cell.accessibilityTraits = .button
			
			cell.accessibilityCustomActions?.removeAll()
			
			let actionName = "\(AppStrings.ExposureSubmissionHotline.callButtonTitle) \(AppStrings.AccessibilityLabel.phoneNumber)"
			cell.accessibilityCustomActions = [
				UIAccessibilityCustomAction(name: actionName, actionHandler: {  _ -> Bool in
					if let url = URL(string: "telprompt:\(AppStrings.ExposureSubmission.hotlineNumber)"),
						UIApplication.shared.canOpenURL(url) {
						UIApplication.shared.open(url, options: [:], completionHandler: nil)
					}
					return true
				})
			]
			
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
	static func html(url: URL?) -> Self {
		.identifier(AppInformationDetailViewController.CellReuseIdentifier.html) { viewController, cell, _  in
			guard let cell = cell as? DynamicTableViewHtmlCell else { return }
			cell.textView.delegate = viewController as? UITextViewDelegate
			cell.textView.isUserInteractionEnabled = true
			cell.textView.dataDetectorTypes = [.link, .phoneNumber]
			
			if let url = url {
				cell.textView.load(from: url)
			}
		}
	}
}
