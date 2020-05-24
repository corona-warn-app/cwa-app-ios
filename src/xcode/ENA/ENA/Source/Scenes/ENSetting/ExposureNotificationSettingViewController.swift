//
//  ENSettingViewController.swift
//  ENA
//
//  Created by Hu, Hao on 11.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

protocol ExposureNotificationSettingViewControllerDelegate: AnyObject {
    typealias Completion = (ExposureNotificationError?) -> Void

    func exposureNotificationSettingViewController(
        _ controller: ExposureNotificationSettingViewController,
        setExposureManagerEnabled enabled: Bool,
        then completion: @escaping Completion
    )
}

final class ExposureNotificationSettingViewController: UITableViewController {

    private weak var delegate: ExposureNotificationSettingViewControllerDelegate?
    @IBOutlet weak var contactTracingSwitch: ENASwitch!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var introductionText: UILabel!
    @IBOutlet weak var enableTrackingLabel: UILabel!

    var exposureManagerEnabled: Bool = false

    init?(
        coder: NSCoder,
        exposureManagerEnabled: Bool,
        delegate: ExposureNotificationSettingViewControllerDelegate
    ) {
        super.init(coder: coder)
        self.exposureManagerEnabled = exposureManagerEnabled
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        setUIText()
        tableView.estimatedRowHeight = 280
        tableView.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    private func setExposureManagerEnabled(
        _ enabled: Bool,
        then completion: ExposureNotificationSettingViewControllerDelegate.Completion
    ) {
        delegate?.exposureNotificationSettingViewController(
            self,
            setExposureManagerEnabled: enabled,
            then: handleErrorIfNeed
        )
    }

    @IBAction func contactTracingValueChanged(_ sender: Any) {
        setExposureManagerEnabled(contactTracingSwitch.isOn, then: handleErrorIfNeed)
    }
}

extension ExposureNotificationSettingViewController {
    
    
    private func setUIText() {
        title = AppStrings.ExposureNotificationSetting.title
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
        }
    }
}

extension ExposureNotificationSettingViewController: ViewControllerUpdatable {
    func updateUI() {
        contactTracingSwitch.setOn(
            exposureManagerEnabled,
            animated: true
        )
    }
}
