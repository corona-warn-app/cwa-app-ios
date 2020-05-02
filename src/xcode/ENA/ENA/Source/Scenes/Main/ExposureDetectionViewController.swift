//
//  ExposureDetectionViewController.swift
//  ENA
//
//  Created by Bormeth, Marc on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

class ExposureDetectionViewController: UIViewController {
    
    @IBOutlet weak var contactTitleLabel: UILabel!
    @IBOutlet weak var lastContactLabel: UILabel!

    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var nextSyncLabel: UILabel!
    
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    
    private lazy var exposureDetectionService = ExposureDetectionService(delegate: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactTitleLabel.text = .lastContactTitle
        lastContactLabel.text = formatLastContact()
        
        lastSyncLabel.text = formatLastSync()
        syncButton.setTitle(.synchronize, for: [])
        nextSyncLabel.text = formatNextSync()
        
        infoTitleLabel.text = .info
        infoTextView.text = .infoText
    }
    
    
    // MARK: - String formatters
    private func formatLastContact() -> String {
        var str: String = .lastContactTextDays
        str = str.replacingOccurrences(of: "$", with: String(3))
        return str
    }
    
    private func formatLastSync() -> String {
        var str: String = .lastSyncInfo

        let lastSync = ExposureDetectionService.lastProcessedPackageTime
        if lastSync == nil {
            str.append(" \(String.never)")
        } else {
            str.append(" \(String.lastSyncData)")
            let hours = Calendar.current.component(.hour, from: lastSync!)
            str = str.replacingOccurrences(of: "$", with: String(hours))
        }

        return str
    }
    
    private func formatNextSync() -> String {
        return "\(String.nextSync) \(String(18)) \(String.hours)"
    }


    @IBAction func refresh(_ sender: UIButton) {
        print("refreshing…")
        exposureDetectionService.detectExposureIfNeeded()
        // Here we have to do what exaclty?
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ExposureDetectionViewController: ExposureDetectionServiceDelegate {
    func didFinish(_ sender: ExposureDetectionService, result: ENExposureDetectionSummary) {
        // FIXME: Use NotificationCenter instead of ExposureDetectionServiceDelegate
        DispatchQueue.main.async {
            self.lastSyncLabel.text = self.formatLastSync()
        }
    }
    
    func didFailWithError(_ sender: ExposureDetectionService, error: Error) {

    }
}

fileprivate extension String {
    static let today = NSLocalizedString("Today", comment: "")
    static let yesterday = NSLocalizedString("Yesterday", comment: "")
    static let hour = NSLocalizedString("Hour", comment: "")
    static let hours = NSLocalizedString("Hours", comment: "")
    static let never = NSLocalizedString("Never", comment: "")
    
    static let lastContactTitle = NSLocalizedString("ExposureDetection_lastContactTitle", comment: "")
    static let lastContactTextDays = NSLocalizedString("ExposureDetection_lastContactText", comment: "")
    
    static let lastSyncInfo = NSLocalizedString("ExposureDetection_lastSyncInfo", comment: "")
    static let lastSyncData = NSLocalizedString("ExposureDetection_lastSyncData", comment: "")
    static let synchronize = NSLocalizedString("ExposureDetection_synchronize", comment: "")
    static let nextSync = NSLocalizedString("ExposureDetection_nextSync", comment: "")
    
    static let info = NSLocalizedString("ExposureDetection_info", comment: "")
    static let infoText = NSLocalizedString("ExposureDetection_infoText", comment: "")
    
}
