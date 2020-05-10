//
//  ExposureNotificationSettingViewController.swift
//  ENA
//
//  Created by Hu, Hao on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

class ExposureNotificationSettingViewController: UIViewController {
    @IBOutlet weak var contactTracingSwitch: UISwitch!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var enableTrackingLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var introductionText: UITextView!
    
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

        // Do any additional setup after loading the view.
        _ = NotificationCenter
            .default
            .addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
                log(message: "[viewDidLoad]: willEnterForegroundNotification, checking notifcation status.")
                self.checkNotificationStatus()
            }

        setUIText()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotificationStatus()
    }

    deinit {
        log(message: "deinit got called.")
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UI and Storyboard
extension ExposureNotificationSettingViewController {
    private func setUIText() {
        titleLabel.text = AppStrings.ExposureNotificationSetting.title
        enableTrackingLabel.text = AppStrings.ExposureNotificationSetting.enableTracing
        introductionLabel.text = AppStrings.ExposureNotificationSetting.introductionTitle
        introductionText.text = AppStrings.ExposureNotificationSetting.introductionText
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func contactTracingValueChanged(_ sender: Any) {
        if contactTracingSwitch.isOn {
            manager.enable {[weak self] error in
                if let error = error {
                    self?.handleEnableError(error)
                } else {
                    self?.checkNotificationStatus()
                }
            }
        } else {
            manager.disable {[weak self]  error in
                if let error = error {
                    self?.handleEnableError(error)
                } else {
                    self?.checkNotificationStatus()
                }
            }
        }
    }
}

extension ExposureNotificationSettingViewController {
    
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
    
    private func checkNotificationStatus() {
        manager.preconditions().contains(.enabled) ?
            contactTracingSwitch.setOn(true, animated: true) :
            contactTracingSwitch.setOn(false, animated: true)
    }
    
}
