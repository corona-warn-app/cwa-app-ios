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
    func refreshView()
}

class RiskView: UIView {

    @IBOutlet weak var titleRiskLabel: UILabel!
    @IBOutlet weak var riskDetailDescriptionLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var daysSinceLastExposureLabel: UILabel!
    @IBOutlet weak var matchedKeyCountLabel: UILabel!

    weak var delegate: RiskViewDelegate?

    @IBAction func viewTapped(_ sender: UIButton) {
        delegate?.refreshView()
    }


    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
