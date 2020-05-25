//
//  ExposureDetectionRoundedView.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 23.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class ExposureDetectionRoundedView: UIView {
	override var bounds: CGRect { didSet { applyRoundedCorners() }}
	
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		applyRoundedCorners()
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		applyRoundedCorners()
	}
	
	
	private func applyRoundedCorners() {
		layer.cornerRadius = min(bounds.width, bounds.height) / 2
	}
}
