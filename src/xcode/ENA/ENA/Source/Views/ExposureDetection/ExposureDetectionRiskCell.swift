//
//  ExposureDetectionRiskCell.swift
//  ENA
//
//  Created by Marc-Peter Eisinger on 23.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit


class ExposureDetectionRiskCell: UITableViewCell {
	@IBOutlet weak var separatorView: UIView!
	
	
	override func prepareForReuse() {
		super.prepareForReuse()
		separatorView.isHidden = false
	}
}
