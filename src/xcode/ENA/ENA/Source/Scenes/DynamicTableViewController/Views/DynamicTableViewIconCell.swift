//
//  DynamicTableViewIconCell.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 19.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class DynamicTableViewIconCell: UITableViewCell {
	@IBOutlet var imageFrameView: UIView!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		imageView?.tintColor = self.tintColor
	}
	
	
	func configure(text: String, image: UIImage?, backgroundColor: UIColor, tintColor: UIColor) {
		self.textLabel?.text = text
		self.imageView?.image = image
		self.imageFrameView.backgroundColor = backgroundColor
		self.imageView?.tintColor = tintColor
	}
}
