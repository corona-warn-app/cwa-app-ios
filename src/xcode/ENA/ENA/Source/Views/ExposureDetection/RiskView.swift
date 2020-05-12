//
//  RiskView.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 09.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

protocol RiskViewDelegate: AnyObject {
    func riskView(riskView: RiskView, didTapRefreshButton sender: UIButton)
}

final class RiskView: UIView {
    // MARK: Properties
    @IBOutlet weak var titleRiskLabel: UILabel!
    @IBOutlet weak var riskDetailDescriptionLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var daysSinceLastExposureLabel: UILabel!
    @IBOutlet weak var matchedKeyCountLabel: UILabel!
    @IBOutlet weak var highRiskDetailView: UIStackView!
    @IBOutlet weak var riskImageView: UIImageView!

    weak var delegate: RiskViewDelegate?

    // MARK: Actions
    @IBAction func viewTapped(_ sender: UIButton) {
        delegate?.riskView(riskView: self, didTapRefreshButton: sender)
    }
}
