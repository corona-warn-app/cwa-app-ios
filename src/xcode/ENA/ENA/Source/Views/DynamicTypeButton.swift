//
//  DynamicTypeButton.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 22.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class DynamicTypeButton: UIButton {
	@IBInspectable var cornerRadius: CGFloat = 8 { didSet { self.layer.cornerRadius = cornerRadius } }
	@IBInspectable var dynamicTypeSize: CGFloat = 0 { didSet { applyDynamicFont() } }
	@IBInspectable var dynamicTypeWeight: String = "" { didSet { applyDynamicFont() } }
	
	
	private var rawFont: UIFont!
	
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	
	private func setup() {
		self.layer.cornerRadius = cornerRadius
		
		applyDynamicFont()
	}
	
	
	private func applyDynamicFont() {
		guard let titleLabel = self.titleLabel else { return }
		if nil == self.rawFont { self.rawFont = titleLabel.font }
		
		guard let textStyle = self.rawFont.textStyle else { return }
		
		titleLabel.adjustsFontForContentSizeCategory = true
		
		let weight = dynamicTypeWeight.isEmpty ? nil : dynamicTypeWeight
		let size = dynamicTypeSize > 0 ? dynamicTypeSize : nil
		
		guard nil != weight || nil != size else { return }
		
		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: UIFont.Weight(weight))
		let font = metrics.scaledFont(for: systemFont)
		
		titleLabel.font = font
	}
}
