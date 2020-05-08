//
//  SettingsViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 28.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import ExposureNotification
import UIKit
import MessageUI

class SettingsViewController: UIViewController {

    @IBOutlet weak var trackingStatusLabel: UILabel!
    @IBOutlet weak var dataInWifiOnlySwitch: UISwitch!
    @IBOutlet weak var sendLogFileView: UIView!
    @IBOutlet weak var tracingStackView: UIStackView!
    @IBOutlet weak var tracingContainerView: UIView!
    @IBOutlet weak var tracingButton: UIButton!
    @IBOutlet weak var notificationStatusLabel: UILabel!
    @IBOutlet weak var notificationsContainerView: UIView!
    @IBOutlet weak var notificationStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    @IBAction func showNotificationSettings(_ sender: Any) {
    }

    @IBAction func showTracingDetails(_ sender: Any) {
        let vc = ExposureNotificationSettingViewController.initiate(for: .exposureNotificationSetting)
        present(vc, animated: true, completion: nil)
    }

    @IBAction func sendLogFile(_ sender: Any) {
        let alert = UIAlertController(title: "Send Log", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Please enter email"
        }

        let action = UIAlertAction(title: "Send Log File", style: .default) { [weak self] _ in
            guard let emailText = alert.textFields?[0].text else {
                return
            }

            if !MFMailComposeViewController.canSendMail() {
                return
            }

            let composeVC = MFMailComposeViewController()
            composeVC.delegate = self
            composeVC.setToRecipients([emailText])
            composeVC.setSubject("Log File")

            guard let logFile = appLogger.getLoggedData() else {
                return
            }
            composeVC.addAttachmentData(logFile, mimeType: "txt", fileName: "Log")

            self?.present(composeVC, animated: true, completion: nil)
        }

        alert.addAction(action)

        self.present(alert, animated: true, completion: nil)
    }

    private func setupView() {
        #if DEBUG
            sendLogFileView.isHidden = false
        #endif
        // receive status of manager
        let status = ENStatus.active
        setTrackingStatus(for: status)
        setNotificationStatus(for: status)

        tracingStackView.isUserInteractionEnabled = false
        notificationStackView.isUserInteractionEnabled = false
        tracingContainerView.setBorder(at: [.top, .bottom], with: UIColor.preferredColor(for: ColorStyle.border), thickness: 1)
        notificationsContainerView.setBorder(at: [.top, .bottom], with: UIColor.preferredColor(for: ColorStyle.border), thickness: 1)
    }

    private func setTrackingStatus(for status: ENStatus) {
        switch status {
        case .active:
            DispatchQueue.main.async {
                self.trackingStatusLabel.text = AppStrings.Settings.trackingStatusActive
            }
        default:
            DispatchQueue.main.async {
                self.trackingStatusLabel.text = AppStrings.Settings.trackingStatusInactive
            }
        }
    }

    private func setNotificationStatus(for status: ENStatus) {
        switch status {
        case .active:
            DispatchQueue.main.async {
                self.notificationStatusLabel.text = AppStrings.Settings.trackingStatusActive
            }
        default:
            DispatchQueue.main.async {
                self.notificationStatusLabel.text = AppStrings.Settings.trackingStatusInactive
            }
        }
    }

}

extension SettingsViewController : UINavigationControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
