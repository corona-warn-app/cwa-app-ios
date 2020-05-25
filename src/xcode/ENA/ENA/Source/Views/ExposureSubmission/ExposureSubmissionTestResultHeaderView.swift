//
//  ExposureSubmissionTestResultHeaderView.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 21.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class ExposureSubmissionTestResultHeaderView: DynamicTableViewHeaderFooterView {
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var receivedLabel: UILabel!
	@IBOutlet weak var statusLabel: UILabel!
	
	
	func configure(title: String, subtitle: String, received: String, status: String?) {
		titleLabel.text = title
		subtitleLabel.text = subtitle
		receivedLabel.text = received
		
		if let status = status {
			statusLabel.superview?.isHidden = false
			statusLabel.text = status
		} else {
			statusLabel.superview?.isHidden = true
		}
	}
}


@IBDesignable
class ExposureSubmissionTestResultView: UIView {
	@IBInspectable var borderColor: UIColor?
	
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		awakeFromNib()
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		clipsToBounds = true
		layer.cornerRadius = 20
		layer.borderWidth = 1
		layer.borderColor = borderColor?.cgColor
	}
}
