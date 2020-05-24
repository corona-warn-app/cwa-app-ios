//
//  ExposureDetectionViewController+DynamicTableViewModel.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 18.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


extension ExposureDetectionViewController {
	func dynamicTableViewModel(for riskLevel: RiskLevel, isTracingEnabled: Bool) -> DynamicTableViewModel {
		if !isTracingEnabled {
			return offModel
		}
		
		switch riskLevel {
		case .unknown: return unknownRiskModel
		case .inactive: return inactiveRiskModel
		case .low: return lowRiskModel
		case .high: return highRiskModel
		}
	}
}


// MARK: - Supported Cell Types

private extension DynamicTableViewModel.Cell {
	private enum ReusableCellIdentifer: String, TableViewCellReuseIdentifiers {
		case risk = "riskCell"
		case riskText = "riskTextCell"
		case riskRefresh = "riskRefreshCell"
		case header = "headerCell"
		case guide = "guideCell"
		case link = "linkCell"
		case hotline = "hotlineCell"
	}
	
	
	static func risk(_ viewController: ExposureDetectionViewController, configure: @escaping CellConfigurator) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.risk) { cell, indexPath in
			cell.backgroundColor = viewController.state.riskTintColor
			cell.textLabel?.textColor = viewController.state.riskContrastColor
			(cell as? ExposureDetectionRiskCell)?.separatorView.isHidden = (indexPath.row == 0)
			configure(cell, indexPath)
		}
	}
	
	
	static func riskLastRiskLevel(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.actualRiskText)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskContacts(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.summary?.numberOfDaysStored ?? 0)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskLastExposure(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.summary?.daysSinceLastExposure ?? 0)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskStored(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			cell.textLabel?.text = String(format: text, viewController.state.summary?.numberOfDaysStored ?? 0)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskRefreshed(text: String, image: UIImage?, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.risk(viewController) { cell, indexPath in
			let formatter = DateFormatter()
			formatter.dateStyle = .medium
			let date: Date! = viewController.state.summary?.lastRefreshDate
			cell.textLabel?.text = String(format: text, nil != date ? formatter.string(from: date) : AppStrings.ExposureDetection.refreshedNever)
			cell.imageView?.image = image
		}
	}
	
	
	static func riskText(text: String, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.riskText) { cell, indexPath in
			cell.backgroundColor = viewController.state.riskTintColor
			cell.textLabel?.textColor = viewController.state.riskContrastColor
			cell.textLabel?.text = text
		}
	}
	
	
	static func riskRefresh(text: String, _ viewController: ExposureDetectionViewController) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.riskRefresh) { cell, indexPath in
			cell.backgroundColor = viewController.state.riskTintColor
			let components = Calendar.current.dateComponents([.minute, .second], from: Date(), to: viewController.state.nextRefresh ?? Date())
			cell.textLabel?.text = String(format: text, components.minute ?? 0, components.second ?? 0)
		}
	}
	
	
	static func header(title: String, subtitle: String) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.header) { cell, indexPath in
			let cell = cell as? ExposureDetectionHeaderCell
			cell?.titleLabel?.text = title
			cell?.subtitleLabel?.text = subtitle
		}
	}
	
	
	static func guide(text: String, image: UIImage?) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.guide) { cell, indexPath in
			cell.textLabel?.text = text
			cell.imageView?.image = image
		}
	}
	
	
	static func link(text: String, url: URL?) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.link, action: .open(url: url)) { cell, indexPath in
			cell.textLabel?.text = text
		}
	}
	
	
	static func hotline(number: String) -> DynamicTableViewModel.Cell {
		.identifier(ReusableCellIdentifer.hotline) { cell, indexPath in
			(cell as? InsetTableViewCell)?.insetContentView.primaryAction = {
				if let url = URL(string: "tel://\(number)") { UIApplication.shared.open(url) }
			}
		}
	}
}


// MARK: - Exposure Detection Model

extension ExposureDetectionViewController {
	private var offModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				footer: .separator(color: .preferredColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)),
				cells: [
					.riskText(text: AppStrings.ExposureDetection.inactiveText, self),
					.riskLastRiskLevel(text: AppStrings.ExposureDetection.lastRiskLevel, image: UIImage(named: "exposure-detection-last-risk-level-contrast"), self),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "exposure-detection-refresh-contrast"), self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
					.guide(text: AppStrings.ExposureDetection.guideHands, image: UIImage(named: "exposure-detection-hands-unknown")),
					.guide(text: AppStrings.ExposureDetection.guideMask, image: UIImage(named: "exposure-detection-mask-unknown")),
					.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "exposure-detection-distance-unknown")),
					.guide(text: AppStrings.ExposureDetection.guideSneeze, image: UIImage(named: "exposure-detection-sneeze-unknown"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.explanationTitle, subtitle: AppStrings.ExposureDetection.explanationSubtitle),
					.regular(text: AppStrings.ExposureDetection.explanationTextOff),
					.link(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: AppStrings.ExposureDetection.hotlineNumber)
				]
			)
		])
	}
	
	private var unknownRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskText(text: AppStrings.ExposureDetection.unknownText, self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
					.guide(text: AppStrings.ExposureDetection.guideHands, image: UIImage(named: "exposure-detection-hands-unknown")),
					.guide(text: AppStrings.ExposureDetection.guideMask, image: UIImage(named: "exposure-detection-mask-unknown")),
					.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "exposure-detection-distance-unknown")),
					.guide(text: AppStrings.ExposureDetection.guideSneeze, image: UIImage(named: "exposure-detection-sneeze-unknown"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.explanationTitle, subtitle: AppStrings.ExposureDetection.explanationSubtitle),
					.regular(text: AppStrings.ExposureDetection.explanationTextUnknown),
					.link(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: AppStrings.ExposureDetection.hotlineNumber)
				]
			)
		])
	}
	
	private var inactiveRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskContacts(text: AppStrings.ExposureDetection.numberOfContacts, image: UIImage(named: "exposure-detection-contacts"), self),
					.riskStored(text: AppStrings.ExposureDetection.numberOfDaysStored, image: UIImage(named: "exposure-detection-tracing-circle"), self),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "exposure-detection-refresh"), self),
					.riskRefresh(text: AppStrings.ExposureDetection.refreshingIn, self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
					.guide(text: AppStrings.ExposureDetection.guideHands, image: UIImage(named: "exposure-detection-hands-inactive")),
					.guide(text: AppStrings.ExposureDetection.guideMask, image: UIImage(named: "exposure-detection-mask-inactive")),
					.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "exposure-detection-distance-inactive")),
					.guide(text: AppStrings.ExposureDetection.guideSneeze, image: UIImage(named: "exposure-detection-sneeze-inactive"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.explanationTitle, subtitle: AppStrings.ExposureDetection.explanationSubtitle),
					.regular(text: AppStrings.ExposureDetection.explanationTextInactive),
					.link(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: AppStrings.ExposureDetection.hotlineNumber)
				]
			)
		])
	}
	
	private var lowRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskContacts(text: AppStrings.ExposureDetection.numberOfContacts, image: UIImage(named: "exposure-detection-contacts"), self),
					.riskStored(text: AppStrings.ExposureDetection.numberOfDaysStored, image: UIImage(named: "exposure-detection-tracing-circle"), self),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "exposure-detection-refresh"), self),
					.riskRefresh(text: AppStrings.ExposureDetection.refreshingIn, self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
					.guide(text: AppStrings.ExposureDetection.guideHands, image: UIImage(named: "exposure-detection-hands-low")),
					.guide(text: AppStrings.ExposureDetection.guideMask, image: UIImage(named: "exposure-detection-mask-low")),
					.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "exposure-detection-distance-low")),
					.guide(text: AppStrings.ExposureDetection.guideSneeze, image: UIImage(named: "exposure-detection-sneeze-low"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.explanationTitle, subtitle: AppStrings.ExposureDetection.explanationSubtitle),
					.regular(text: AppStrings.ExposureDetection.explanationTextLow),
					.link(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: AppStrings.ExposureDetection.hotlineNumber)
				]
			)
		])
	}
	
	private var highRiskModel: DynamicTableViewModel {
		DynamicTableViewModel([
			.section(
				header: .none,
				cells: [
					.riskContacts(text: AppStrings.ExposureDetection.numberOfContacts, image: UIImage(named: "exposure-detection-contacts"), self),
					.riskStored(text: AppStrings.ExposureDetection.lastExposure, image: UIImage(named: "exposure-detection-tracing-calendar"), self),
					.riskStored(text: AppStrings.ExposureDetection.numberOfDaysStored, image: UIImage(named: "exposure-detection-tracing-circle"), self),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "exposure-detection-refresh"), self),
					.riskRefresh(text: AppStrings.ExposureDetection.refreshingIn, self)
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
					.guide(text: AppStrings.ExposureDetection.guideHome, image: UIImage(named: "exposure-detection-home-high")),
					.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "exposure-detection-distance-high")),
					.guide(text: AppStrings.ExposureDetection.guideQuestions, image: UIImage(named: "exposure-detection-phone-high"))
				]
			),
			.section(
				header: .none,
				cells: [
					.header(title: AppStrings.ExposureDetection.explanationTitle, subtitle: AppStrings.ExposureDetection.explanationSubtitle),
					.regular(text: AppStrings.ExposureDetection.explanationTextHigh),
					.link(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
				]
			),
			.section(
				header: .none,
				cells: [
					.hotline(number: AppStrings.ExposureDetection.hotlineNumber)
				]
			)
		])
	}
}
