//
//  RiskView.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 09.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

protocol RiskViewDelegate: class {
    func refreshButtonWasTapped(riskView: RiskView)
}

class RiskView: UIView {

    @IBOutlet weak var titleRiskLabel: UILabel!
    @IBOutlet weak var riskDetailDescriptionLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var daysSinceLastExposureLabel: UILabel!
    @IBOutlet weak var matchedKeyCountLabel: UILabel!
    @IBOutlet weak var highRiskDetailView: UIStackView!
    @IBOutlet weak var riskImageView: UIImageView!

    weak var delegate: RiskViewDelegate?

    @IBAction func viewTapped(_ sender: UIButton) {
        delegate?.refreshButtonWasTapped(riskView: self)
    }


    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
