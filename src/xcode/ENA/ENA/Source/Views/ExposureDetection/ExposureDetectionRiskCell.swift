//
//  ExposureDetectionRiskCell.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 18.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class ExposureDetectionRiskCell: UIView, NibLoadable {
	@IBOutlet weak var contactLabel: UILabel!
	@IBOutlet weak var lastExposureSeparator: UIView!
	@IBOutlet weak var lastExposureView: UIView!
	@IBOutlet weak var lastExposureLabel: UILabel!
	@IBOutlet weak var lastCheckSeparator: UIView!
	@IBOutlet weak var lastCheckView: UIView!
	@IBOutlet weak var lastCheckLabel: UILabel!
	
	
	private var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}()
	
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupFromNib()
	}
	
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupFromNib()
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setupFromNib()
	}
	
	
	func configure(for riskLevel: RiskLevel, contacts: Int, lastExposure: Int?, lastCheck: Date?) {
		self.nibView.backgroundColor = riskLevel.color
		
		if riskLevel == .unknown {
			self.contactLabel.text = AppStrings.ExposureDetection.unknownText
		} else {
			self.contactLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.contacts, contacts)
			
			if let lastExposure = lastExposure {
				self.lastExposureLabel.text = String.localizedStringWithFormat(AppStrings.ExposureDetection.lastExposure, lastExposure)
			}
			
			if let lastCheck = lastCheck {
				self.lastCheckLabel.text = AppStrings.ExposureDetection.lastCheck + " " + dateFormatter.string(from: lastCheck)
			} else {
				self.lastCheckLabel.text = AppStrings.ExposureDetection.lastCheckNever
			}
		}

		self.lastExposureSeparator.isHidden = riskLevel != .high
		self.lastExposureView.isHidden = riskLevel != .high
		self.lastCheckSeparator.isHidden = riskLevel == .unknown
		self.lastCheckView.isHidden = riskLevel == .unknown
	}
}


private extension RiskLevel {
	var color: UIColor {
		switch self {
		case .low: return .preferredColor(for: .positive)
		case .high: return .preferredColor(for: .negative)
		case .unknown: return .preferredColor(for: .unknownRisk)
		default: return .preferredColor(for: .unknownRisk)
		}
	}
}
