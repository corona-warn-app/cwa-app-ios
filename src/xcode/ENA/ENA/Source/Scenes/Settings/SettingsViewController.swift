//
//  SettingsViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var trackingStatusLabel: UILabel!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var dataInWifiOnlySwitch: UISwitch!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    private func setTrackingStatus(for status: ENStatus) {
        switch status {
        case .active:
            DispatchQueue.main.async {
                self.trackingStatusLabel.text = "Aktiv"
            }
        default:
            DispatchQueue.main.async {
                self.trackingStatusLabel.text = "Inaktiv"
            }
        }
    }

}
