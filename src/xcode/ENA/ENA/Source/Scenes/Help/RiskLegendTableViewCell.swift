//
//  RiskLegendTableViewCell.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 11.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

class RiskLegendTableViewCell: UITableViewCell {
    static var identifier = "RiskLegendCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconBackgroundView: UIView!
    
}
