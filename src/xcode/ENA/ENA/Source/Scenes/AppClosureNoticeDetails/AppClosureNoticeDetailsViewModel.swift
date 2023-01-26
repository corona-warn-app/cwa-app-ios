//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class AppClosureNoticeDetailsViewModel {
	
	init (
		cclService: CCLServable,
		statusTabNotice: StatusTabNotice
	) {
		self.cclService = cclService
		self.statusTabNotice = statusTabNotice
	}

	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel {
		var cells: [DynamicCell] = []
		
		if let titleText = statusTabNotice.titleText?.localized(cclService: cclService), !titleText.isEmpty {
			cells.append(
				.title1(
					text: titleText,
					accessibilityIdentifier: AccessibilityIdentifiers.Home.AppClosureNoticeCell.Details.titleLabel
				)
			)
		}
		
		if let subtitleText = statusTabNotice.subtitleText?.localized(cclService: cclService), !subtitleText.isEmpty {
			cells.append(
				.subheadline(
					text: subtitleText,
					color: .enaColor(for: .textPrimary2),
					accessibilityIdentifier: AccessibilityIdentifiers.Home.AppClosureNoticeCell.Details.subtitleLabel
				) { _, cell, _ in
					cell.contentView.preservesSuperviewLayoutMargins = false
					
					cell.contentView.layoutMargins.top = 0
				}
			)
		}

		if let longText = statusTabNotice.longText?.localized(cclService: cclService), !longText.isEmpty {
			cells.append(
				.body(
					text: longText,
				    accessibilityIdentifier: AccessibilityIdentifiers.Home.AppClosureNoticeCell.Details.longTextLabel
				)
			)
		}
		
		if let faqAnchor = statusTabNotice.faqAnchor, !faqAnchor.isEmpty {
			cells.append(
				.link(
					text: AppStrings.HealthCertificate.Person.faq,
					url: URL(string: LinkHelper.urlString(suffix: faqAnchor, type: .faq)),
					accessibilityIdentifier: AccessibilityIdentifiers.Home.AppClosureNoticeCell.Details.faqLabel
				)
			)
		}
		
		return DynamicTableViewModel.with {
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_AppClosure_Notice"),
						accessibilityIdentifier: AccessibilityIdentifiers.Home.AppClosureNoticeCell.Details.image
					),
					cells: cells
				)
			)
		}
	}
	
	// MARK: - Private
	
	private let cclService: CCLServable
	private let statusTabNotice: StatusTabNotice
}
