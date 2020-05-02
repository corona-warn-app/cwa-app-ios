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
        let lastContactStringFormat = NSLocalizedString("lastDays", comment: "")
        lastContactLabel.text = String.localizedStringWithFormat(lastContactStringFormat, 3)


        updateLastSyncLabel()
        syncButton.setTitle(.synchronize, for: [])
        nextSyncLabel.text = formatNextSync()
        
        infoTitleLabel.text = .info
        infoTextView.text = .infoText
    }
    
    private func updateLastSyncLabel() {

        let lastContactStringFormat = NSLocalizedString("lastHours", comment: "")
        guard let lastSync = ExposureDetectionService.lastProcessedPackageTime else {
            self.lastSyncLabel.text = NSLocalizedString("unknown_time", comment: "")
            return
        }
        let hours = Calendar.current.component(.hour, from: lastSync)
        self.lastSyncLabel.text =  String.localizedStringWithFormat(lastContactStringFormat, hours)
    }
    
    private func formatNextSync() -> String {
        return "\(String.nextSync) \(String(18)) "
    }


    @IBAction func refresh(_ sender: UIButton) {
        exposureDetectionService.detectExposureIfNeeded()
    }
}

extension ExposureDetectionViewController: ExposureDetectionServiceDelegate {
    func didFinish(_ sender: ExposureDetectionService, result: ENExposureDetectionSummary) {
        DispatchQueue.main.async {
            self.updateLastSyncLabel()
        }
    }
    
    func didFailWithError(_ sender: ExposureDetectionService, error: Error) {

    }
}

fileprivate extension String { 

    static let lastContactTitle = NSLocalizedString("ExposureDetection_lastContactTitle", comment: "")
    
    static let lastSyncInfo = NSLocalizedString("ExposureDetection_lastSyncInfo", comment: "")
    static let synchronize = NSLocalizedString("ExposureDetection_synchronize", comment: "")
    static let nextSync = NSLocalizedString("ExposureDetection_nextSync", comment: "")
    
    static let info = NSLocalizedString("ExposureDetection_info", comment: "")
    static let infoText = NSLocalizedString("ExposureDetection_infoText", comment: "")
    
}
