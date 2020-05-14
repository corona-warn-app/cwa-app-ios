//
//  ENSettingViewController.swift
//  ENA
//
//  Created by Hu, Hao on 11.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class ExposureNotificationSettingViewController: UITableViewController {
    
    @IBOutlet weak var contactTracingSwitch: ENASwitch!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var introductionText: UILabel!
    @IBOutlet weak var enableTrackingLabel: UILabel!
    
    
    let manager: ExposureManager
    init?(coder: NSCoder, manager: ExposureManager) {
        self.manager = manager
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationCenter()
        setUIText()
        tableView.estimatedRowHeight = 280
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotificationStatus()
    }

    
    @IBAction func contactTracingValueChanged(_ sender: Any) {
        if contactTracingSwitch.isOn {
            manager.enable {[weak self] error in
                self?.handleErrorIfNeed(error)
            }
        } else {
            manager.disable {[weak self]  error in
                self?.handleErrorIfNeed(error)
            }
        }
    }
}

extension ExposureNotificationSettingViewController {
    
    
    private func setUIText() {
        enableTrackingLabel.text = AppStrings.ExposureNotificationSetting.enableTracing
        introductionLabel.text = AppStrings.ExposureNotificationSetting.introductionTitle
        introductionText.text = AppStrings.ExposureNotificationSetting.introductionText
    }
    
    
    private func handleEnableError(_ error: ExposureNotificationError) {
        switch error {
        case .exposureNotificationAuthorization:
            logError(message: "Fail to enable exposureNotificationAuthorization")
            alertError(message: "Fail to enable: exposureNotificationAuthorization", title: "Error")
        case .exposureNotificationRequired:
            logError(message: "Fail to enable")
            alertError(message: "exposureNotificationAuthorization", title: "Error")
        }
    }
    
    
    private func handleErrorIfNeed(_ error: ExposureNotificationError?) {
        if let error = error {
            handleEnableError(error)
        } else {
            checkNotificationStatus()
        }
    }
    
    private func checkNotificationStatus() {
        manager.preconditions().contains(.enabled) ?
            contactTracingSwitch.setOn(true, animated: true) :
            contactTracingSwitch.setOn(false, animated: true)
    }
    
    private func setupNotificationCenter() {
        _ = NotificationCenter
            .default
            .addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
                log(message: "[viewDidLoad]: willEnterForegroundNotification, checking notifcation status.")
                self.checkNotificationStatus()
            }
    }
    
}
