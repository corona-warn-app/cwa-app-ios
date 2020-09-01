//
//  AppInformationModel.swift
//  ENA
//
//  Created by Vogel, Andreas on 01.09.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

extension DynamicCell {
	static func phone(text: String, number: String, accessibilityIdentifier: String?) -> Self {
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
	
	static func imprintHeadlineWithoutBottomInset(text: String, accessibilityIdentifier: String?) -> Self {
		.headline(text: text, accessibilityIdentifier: accessibilityIdentifier) { _, cell, _ in
			cell.contentView.preservesSuperviewLayoutMargins = false
			cell.contentView.layoutMargins.bottom = 0
			cell.accessibilityIdentifier = accessibilityIdentifier
			cell.accessibilityTraits = .header
		}
	}
	
	static func bodyWithoutTopInset(text: String, style: TextCellStyle = .label, accessibilityIdentifier: String?) -> Self {
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

extension DynamicAction {
	static var safari: Self {
		.execute { viewController in
			LinkHelper.showWebPage(from: viewController, urlString: AppStrings.SafariView.targetURL)
		}
	}
	
	static func push(model: DynamicTableViewModel, separators: Bool = false, withTitle title: String) -> Self {
		.execute { viewController in
			let detailViewController = AppInformationDetailViewController()
			detailViewController.title = title
			detailViewController.dynamicTableViewModel = model
			detailViewController.separatorStyle = separators ? .singleLine : .none
			viewController.navigationController?.pushViewController(detailViewController, animated: true)
		}
	}
}
