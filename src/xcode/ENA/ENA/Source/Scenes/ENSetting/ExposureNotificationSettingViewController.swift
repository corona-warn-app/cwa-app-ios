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

    //TODO: This should be checked later.

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter
            .default
            .addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { notifcation in
                print("[viewDidLoad]: willEnterForegroundNotification, checking notifcation status.")
                self.checkNotifcationEnablement()
            }

        setUIText()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkNotifcationEnablement()
    }

    deinit {
        print("[ExposureNotificationSettingViewController deinit] got called.")
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
        let enManager = ENManager()
        enManager.activate { error in
            if let error = error as NSError? {
                self.alertError(message: error.localizedDescription, title: "Error")
                return
            }

            assert(enManager.exposureNotificationStatus != .unknown)
            let isEnable = self.contactTracingSwitch.isOn
            enManager.setExposureNotificationEnabled(isEnable) { error in
                if let error = error as? ENError {
                    if error.code == .notAuthorized {
                        //TODO:Tell the user to enable it on the setting, It can help users to jump to the settings page.
                        print("[contactTracingValueChanged]: Tell the user to enable it on the setting")
                    }

                    print("[contactTracingValueChanged] Error occurs, while setExposureNotificationEnabled. Error code is \(error.code.rawValue) ")
                }

                //Check status again.
                self.checkNotifcationStatus(for: enManager)
                enManager.invalidate()
            }
        }

        enManager.invalidationHandler = {
            
            //Oberserver the behaviour of ENManager.
            print("[contactTracingValueChanged]: EnManaber invalid")
        }
    }
}

extension ExposureNotificationSettingViewController {
    private func checkNotifcationEnablement(){
        let enManager = ENManager()

        enManager.activate { (error) in
            if let error = error as NSError? {
                print("[contactTracingValueChanged]: \(error.localizedDescription)")
                return
            }

            assert(enManager.exposureNotificationStatus != .unknown)
            let exposureEnabled = enManager.exposureNotificationEnabled
            self.contactTracingSwitch.setOn(exposureEnabled, animated: true)
            enManager.invalidate()
            print("")
        }

        enManager.invalidationHandler = {
            //Oberserver the behaviour of ENManager.
            print("[checkNotifcationEnablement]: EnManaber invalidationHandler got called.")
        }
    }

    private func checkNotifcationStatus(for enManager: ENManager) {
        assert(enManager.exposureNotificationStatus != .unknown)
        let status = enManager.exposureNotificationStatus
        if status == .active || status == .disabled{
            let isEnable = enManager.exposureNotificationEnabled
            contactTracingSwitch.setOn(isEnable, animated: true)
            } else {
			switch status {
			case .bluetoothOff:
				alertError(message: "Bluetooth is off", title: "Error")
				break
//            case .disabled:
//                //Q: What is the different between this disable and the exposureNotificationEnabled?
//                alertError(message: "Exposure Notification is disabled", title: "Error")
//                break
			case .restricted:
				alertError(message: "Exposure Notification is not active due to system restrictions, such as parental controls", title: "Error")
				break
			case .unknown:
				alertError(message: "Status of Exposure Notification is unknown. This is the status before ENManager has activated successfully", title: "Error")
				break
			default:
				break
            }
        }
    }
}
