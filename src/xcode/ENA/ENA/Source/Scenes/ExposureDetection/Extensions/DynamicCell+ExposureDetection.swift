//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import UIKit
import OpenCombine

// MARK: - Supported Cell Types

extension DynamicCell {

	private static let relativeDateTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.doesRelativeDateFormatting = true
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}()

	private static func exposureDetectionCell(_ identifier: TableViewCellReuseIdentifiers, action: DynamicAction = .none, accessoryAction: DynamicAction = .none, configure: GenericCellConfigurator<ExposureDetectionViewController>? = nil) -> DynamicCell {
		.custom(withIdentifier: identifier, action: action, accessoryAction: accessoryAction, configure: configure)
	}

	static func risk(hasSeparator: Bool = true, configure: @escaping GenericCellConfigurator<ExposureDetectionViewController>) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.risk) { viewController, cell, indexPath in
			let viewModel = viewController.viewModel
			cell.backgroundColor = viewModel.riskBackgroundColor
			cell.tintColor = viewModel.riskContrastTintColor
			cell.textLabel?.textColor = viewModel.titleTextColor
			if let cell = cell as? ExposureDetectionRiskCell {
				cell.separatorView.isHidden = (indexPath.row == 0) || !hasSeparator
				cell.separatorView.backgroundColor = viewModel.riskSeparatorColor
			}
			configure(viewController, cell, indexPath)
		}
	}

	static func riskLastRiskLevel(hasSeparator: Bool = true, text: String, image: UIImage?) -> DynamicCell {
		.risk(hasSeparator: hasSeparator) { viewController, cell, _ in
			let viewModel = viewController.viewModel
			cell.textLabel?.text = String(format: text, viewModel.previousRiskTitle)
			cell.imageView?.image = image
		}
	}

	static func riskContacts(text: String, image: UIImage?) -> DynamicCell {
		.risk { viewController, cell, _ in
			cell.textLabel?.text = String(format: text, viewController.viewModel.riskDetails?.numberOfDaysWithRiskLevel ?? 0)
			cell.imageView?.image = image
		}
	}

	static func riskLastExposure(text: String, image: UIImage?) -> DynamicCell {
		.risk { viewController, cell, _ in
			cell.imageView?.image = image

			guard let mostRecentDateWithHighRisk = viewController.viewModel.riskDetails?.mostRecentDateWithRiskLevel else {
				assertionFailure("mostRecentDateWithRiskLevel must be set on high risk state")
				cell.textLabel?.text = ""

				return
			}

			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium

			let formattedMostRecentDateWithHighRisk = dateFormatter.string(from: mostRecentDateWithHighRisk)
			cell.textLabel?.text = .localizedStringWithFormat(text, formattedMostRecentDateWithHighRisk)
		}
	}

	static func riskStored(daysSinceInstallation: Int) -> DynamicCell {
		.risk { _, cell, _ in
			cell.textLabel?.text = String(format: AppStrings.ExposureDetection.daysSinceInstallation, daysSinceInstallation)
			cell.imageView?.image = UIImage(named: "Icons-DaysSinceInstall")
		}
	}

	static func riskRefreshed(text: String, image: UIImage?) -> DynamicCell {
		.risk { viewController, cell, _ in
			var valueText: String

			if	let enfRiskCalulationResult = viewController.store.enfRiskCalculationResult,
				  let checkinRiskCalculationResult = viewController.store.checkinRiskCalculationResult,
				  let date = Risk(enfRiskCalculationResult: enfRiskCalulationResult, checkinCalculationResult: checkinRiskCalculationResult).details.calculationDate {
				
				valueText = relativeDateTimeFormatter.string(from: date)
			} else {
				valueText = AppStrings.ExposureDetection.refreshedNever
			}

			cell.textLabel?.text = String(format: text, valueText)
			cell.imageView?.image = image
		}
	}

	static func riskText(text: String) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.riskText) { viewController, cell, _ in
			let viewModel = viewController.viewModel
			cell.backgroundColor = viewModel.riskBackgroundColor
			cell.textLabel?.textColor = viewModel.titleTextColor
			cell.textLabel?.text = text
		}
	}

	static func riskLoading(text: String) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.riskLoading) { viewController, cell, _ in
			let cell = cell as? ExposureDetectionLoadingCell
			let viewModel = viewController.viewModel

			cell?.backgroundColor = viewModel.riskBackgroundColor
			cell?.textLabel?.textColor = viewModel.titleTextColor
			cell?.textLabel?.text = text
			cell?.activityIndicatorView.color = viewModel.titleTextColor
		}
	}

	static func header(title: String, subtitle: String) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.header) { _, cell, _ in
			let cell = cell as? ExposureDetectionHeaderCell
			cell?.titleLabel?.text = title
			cell?.subtitleLabel?.text = subtitle
			cell?.titleLabel?.accessibilityTraits = .header
		}
	}

	static func guide(text: String, image: UIImage?) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.guide) { viewController, cell, _ in
			cell.tintColor = viewController.viewModel.riskTintColor
			cell.textLabel?.text = text
			cell.imageView?.image = image
		}
	}

	static func guide(attributedString text: NSAttributedString, image: UIImage?, link: URL? = nil, accessibilityIdentifier: String? = nil) -> DynamicCell {
		var action: DynamicAction = .none
		if let url = link {
			action = .open(url: url)
		}
		return .exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.guide, action: action) { viewController, cell, _ in
			cell.tintColor = viewController.viewModel.riskTintColor
			cell.textLabel?.attributedText = text
			cell.imageView?.image = image
			cell.accessibilityIdentifier = accessibilityIdentifier
		}
	}

	static func guide(image: UIImage?, text: [String]) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.longGuide) { viewController, cell, _ in
			cell.tintColor = viewController.viewModel.riskTintColor
			(cell as? ExposureDetectionLongGuideCell)?.configure(image: image, text: text)
		}
	}

	static func guide(image: UIImage?, attributedStrings text: [NSAttributedString]) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.longGuide) { viewController, cell, _ in
			cell.tintColor = viewController.viewModel.riskTintColor
			(cell as? ExposureDetectionLongGuideCell)?.configure(image: image, attributedText: text)
		}
	}

	static func link(text: String, url: URL?) -> DynamicCell {
		.custom(withIdentifier: ExposureDetectionViewController.ReusableCellIdentifier.link, action: .open(url: url)) { _, cell, _ in
			cell.textLabel?.text = text
		}
	}

	static func hotline(number: String) -> DynamicCell {
		.exposureDetectionCell(ExposureDetectionViewController.ReusableCellIdentifier.hotline) { _, cell, _ in
			(cell as? ExposureDetectionHotlineCell)?.hotlineContentView.primaryAction = {
				if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }
			}
		}
	}
}
