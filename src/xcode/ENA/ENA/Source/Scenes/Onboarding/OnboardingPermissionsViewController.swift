//
//  OnboardingPermissionsViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol OnboardingPermissionsViewControllerDelegate: AnyObject {
    func permissionsDidChange(onboardingPermissions: OnboardingPermissionsViewController)
}

class OnboardingPermissionsViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var bluetoothLabel: UILabel!
    @IBOutlet var bluetoothSwitch: UISwitch!

    @IBOutlet var notificationLabel: UILabel!
    @IBOutlet var notificationSwitch: UISwitch!
    
    weak var delegate: OnboardingPermissionsViewControllerDelegate?
    
    var onboardingPermissions: OnboardingPermissions? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bluetoothSwitch.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        notificationSwitch.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        updateUI()
    }
    
    @objc private func switchStateDidChange(_ switch: UISwitch) {
        delegate?.permissionsDidChange(onboardingPermissions: self)
    }
    
    private func updateUI() {
        guard isViewLoaded else { return }
        titleLabel.text = onboardingPermissions?.title
        if let imageName = onboardingPermissions?.imageName {
            imageView.image = UIImage(named: imageName)
        } else {
            imageView.image = nil
        }
        if let permissions = onboardingPermissions?.permissions {
            for permission in permissions {
                switch permission {
                case .bluetooth:
                    bluetoothLabel.text = permission.title
                    bluetoothSwitch.isOn = false
                case .notifications:
                    notificationLabel.text = permission.title
                    notificationSwitch.isOn = false
                }
            }
        } else {
            bluetoothLabel.text = nil
            bluetoothSwitch.isOn = false
            notificationLabel.text = nil
            notificationSwitch.isOn = false
        }
    }
    
}
 
extension OnboardingPermissionsViewController: OnboardingNextPageAvailable {
    func isNextPageAvailable() -> Bool {
        let isBluetoothAvailable = bluetoothSwitch.isOn
        let isNotificationsAvailable = notificationSwitch.isOn
        return isBluetoothAvailable && isNotificationsAvailable
    }
}
