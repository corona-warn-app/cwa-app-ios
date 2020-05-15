//
//  DynamicTypeLabel.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class DynamicTypeLabel: UILabel {
	@IBInspectable var dynamicTypeSize: CGFloat = 0 { didSet { applyDynamicFont() } }
	@IBInspectable var dynamicTypeWeight: String = "" { didSet { applyDynamicFont() } }
	
	
	private var rawFont: UIFont!
	
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		applyDynamicFont()
	}
	
	
	override func awakeFromNib() {
		applyDynamicFont()
	}
	
	
	private func applyDynamicFont() {
		if nil == self.rawFont { self.rawFont = self.font }
		
		guard let textStyle = self.rawFont.textStyle else { return }
		
		let weight = dynamicTypeWeight.isEmpty ? nil : dynamicTypeWeight
		let size = dynamicTypeSize > 0 ? dynamicTypeSize : nil
		
		guard nil != weight || nil != size else { return }
		
		let metrics = UIFontMetrics(forTextStyle: textStyle)
		let description = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
		let systemFont = UIFont.systemFont(ofSize: size ?? description.pointSize, weight: UIFont.Weight(weight))
		let font = metrics.scaledFont(for: systemFont)
		
		self.font = font
	}
}
