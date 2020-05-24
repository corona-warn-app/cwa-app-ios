//
//  InsetTableViewCell.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 23.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class InsetTableViewCell: UITableViewCell {
	@IBOutlet weak var insetContentView: InsetTableViewCellContentView!
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		insetContentView.primaryAction = nil
	}
}


@IBDesignable
class InsetTableViewCellContentView: UIView {
	var primaryAction: (() -> Void)?
	
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		awakeFromNib()
	}
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.layer.cornerRadius = 16
		self.layer.shadowRadius = 36
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOpacity = 0.15
		self.layer.shadowOffset = CGSize(width: 0, height: 10)
	}
	
	
	@IBAction func triggerPrimaryAction() {
		primaryAction?()
	}
}
