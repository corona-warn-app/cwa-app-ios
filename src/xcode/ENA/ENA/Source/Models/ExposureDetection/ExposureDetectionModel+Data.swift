//
//  ExposureDetectionModelData.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 18.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


extension ExposureDetectionModel {
	static func model(for riskLevel: RiskLevel) -> ExposureDetectionModel {
		switch riskLevel {
		case .low:
			return .lowRisk
		case .high:
			return .highRisk
		case .unknown:
			return .unknownRisk
		default:
			return .unknownRisk
		}
	}
}
	
	
extension ExposureDetectionModel {
	static let lowRisk = ExposureDetectionModel(
		content: [
			.headline(text: AppStrings.ExposureDetection.title),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide1),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide2),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide3),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide4),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide5),
			.title(text: AppStrings.ExposureDetection.detailTitle),
			.text(text: AppStrings.ExposureDetection.detailTextLow),
			.more(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
		],
		
		
		help: AppStrings.ExposureDetection.help,
		hotline: (text: AppStrings.ExposureDetection.hotline, number: AppStrings.ExposureDetection.hotlineNumber),
		checkButton: AppStrings.ExposureDetection.checkNow
	)
	
	
	static let highRisk = ExposureDetectionModel(
		content: [
			.headline(text: AppStrings.ExposureDetection.title),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.highGuide1),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.highGuide2),
			.phone(text: AppStrings.ExposureDetection.healthDepartment, number: AppStrings.ExposureDetection.healthDepartmentNumber),
			.title(text: AppStrings.ExposureDetection.detailTitle),
			.text(text: AppStrings.ExposureDetection.detailTextHigh),
			.more(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
		],
		
		
		help: AppStrings.ExposureDetection.help,
		hotline: (text: AppStrings.ExposureDetection.hotline, number: AppStrings.ExposureDetection.hotlineNumber),
		checkButton: AppStrings.ExposureDetection.checkNow
	)

	
	static let unknownRisk = ExposureDetectionModel(
		content: [
			.headline(text: AppStrings.ExposureDetection.title),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide1),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide2),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide3),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide4),
			.guide(image: UIImage(systemName: "house.fill"), text: AppStrings.ExposureDetection.guide5),
			.title(text: AppStrings.ExposureDetection.detailTitle),
			.text(text: AppStrings.ExposureDetection.detailTextUnknown),
			.more(text: AppStrings.ExposureDetection.moreInformation, url: URL(string: AppStrings.ExposureDetection.moreInformationUrl))
		],
		
		
		help: AppStrings.ExposureDetection.help,
		hotline: (text: AppStrings.ExposureDetection.hotline, number: AppStrings.ExposureDetection.hotlineNumber),
		checkButton: AppStrings.ExposureDetection.checkNow
	)
}
