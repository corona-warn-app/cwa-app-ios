//
//  DynamicTypeTableViewCell.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class DynamicTypeTableViewCell: UITableViewCell {
	var textStyle: UIFont.TextStyle? { nil }
	var fontSize: CGFloat? { nil }
	var fontWeight: UIFont.Weight? { nil }
	
	
	required init?(coder: NSCoder) {
		fatalError("Not implemented!")
	}
	
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		selectionStyle = .none
		
		if let textStyle = self.textStyle {
			textLabel?.font = UIFont.preferredFont(forTextStyle: textStyle).scaledFont(size: self.fontSize, weight: self.fontWeight)
			textLabel?.adjustsFontForContentSizeCategory = true
			textLabel?.numberOfLines = 0
		}
	}
	

	override func awakeFromNib() {
		super.awakeFromNib()
		
		if let textStyle = self.textStyle {
			textLabel?.font = UIFont.preferredFont(forTextStyle: textStyle).scaledFont(size: self.fontSize, weight: self.fontWeight)
			textLabel?.adjustsFontForContentSizeCategory = true
			textLabel?.numberOfLines = 0
		}
	}
}


extension DynamicTypeTableViewCell {
	class Regular: DynamicTypeTableViewCell {
		override var textStyle: UIFont.TextStyle? { .body }
		override var fontSize: CGFloat? { 17 }
		override var fontWeight: UIFont.Weight? { .regular }
	}
	
	
	class Semibold: DynamicTypeTableViewCell {
		override var textStyle: UIFont.TextStyle? { .body }
		override var fontSize: CGFloat? { 17 }
		override var fontWeight: UIFont.Weight? { .semibold }
	}
	
	
	class Bold: DynamicTypeTableViewCell {
		override var textStyle: UIFont.TextStyle? { .body }
		override var fontSize: CGFloat? { 17 }
		override var fontWeight: UIFont.Weight? { .bold }
	}
}
