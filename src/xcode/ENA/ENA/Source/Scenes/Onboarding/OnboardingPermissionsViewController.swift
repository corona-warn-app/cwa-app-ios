//
//  OnboardingPermissionsViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import CoreBluetooth
import ExposureNotification

protocol OnboardingPermissionsViewControllerDelegate: AnyObject {
    func permissionsDidChange(onboardingPermissions: OnboardingPermissionsViewController)
}

class OnboardingPermissionsViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var bluetoothLabel: UILabel!
    @IBOutlet private var bluetoothButton: UIButton!

    @IBOutlet private var notificationLabel: UILabel!
    @IBOutlet private var explosureNotificationsButton: UIButton!
    
    private var centralManager: CBCentralManager!
    
    private var isBluetoothAuthorized: Bool {
        CBCentralManager.authorization == .allowedAlways
    }
    
    private var isExplosureNotificationsAuthorized: Bool {
        ENManager.authorizationStatus == .authorized
    }
    
    weak var delegate: OnboardingPermissionsViewControllerDelegate?
    
    private var onboardingPermissions: OnboardingPermissions = OnboardingPermissions.testData() {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction private func bluetoothButtonTapped(_ sender: UIButton) {
        askBluetoothPermissions()
    }
    
    @IBAction private func explosureNotificationsButtonTapped(_ sender: UIButton) {
        askExposureNotificationsPermissions()
    }
    
    private func updateUI() {
        guard isViewLoaded else { return }
        titleLabel.text = onboardingPermissions.title
        imageView.image = UIImage(named: onboardingPermissions.imageName)
        
        bluetoothLabel.text = onboardingPermissions.bluetoothTitle
        notificationLabel.text = onboardingPermissions.notificationsTitle
        
        configureBluetoothButton()
        configureExposureNotificationsButton()
    }
    
    // MARK: Bluetooth
    
    private func configureBluetoothButton() {
        let authorization = CBCentralManager.authorization
        bluetoothButton.isEnabled = authorization == .notDetermined
        switch authorization {
        case .notDetermined:
            bluetoothButton.setTitle("Please provide permissions", for: .normal)
        case .restricted:
            bluetoothButton.setTitle("Access is restricted", for: .normal)
        case .denied:
            bluetoothButton.setTitle("Please go to the settings", for: .normal)
        case .allowedAlways:
            bluetoothButton.setTitle("Access is provided", for: .normal)
        @unknown default:
            bluetoothButton.setTitle("Unknown", for: .normal)
        }
    }
    
    private func askBluetoothPermissions() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: Exposure notifications
    
    private func configureExposureNotificationsButton() {
        let authorization = ENManager.authorizationStatus
        // explosureNotificationsButton.isEnabled = authorization == .unknown
        switch authorization {
        case .unknown:
            explosureNotificationsButton.setTitle("Please provide permissions", for: .normal)
        case .restricted:
            explosureNotificationsButton.setTitle("Access is restricted", for: .normal)
        case .notAuthorized:
            explosureNotificationsButton.setTitle("Please go to the settings", for: .normal)
        case .authorized:
            explosureNotificationsButton.setTitle("Access is provided", for: .normal)
        @unknown default:
            explosureNotificationsButton.setTitle("Unknown", for: .normal)
        }
    }
    
    private func askExposureNotificationsPermissions() {
        ExposureManager.shared.manager.setExposureNotificationEnabled(true) { error in
            if let error = error as? ENError, error.code == .notAuthorized {
                print("Encourage the user to consider enabling Exposure Notifications.")
                // self.openSettings()
            } else if let error = error {
                self.showError(error, from: self)
            } else {
                print("GOOD")
            }
            self.configureExposureNotificationsButton()
            self.delegate?.permissionsDidChange(onboardingPermissions: self)
        }
    }
    
    // MARK: - Open Settings
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showError(_ error: Error, from viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        viewController.present(alert, animated: true, completion: nil)
    }
}
 
extension OnboardingPermissionsViewController: OnboardingNextPageAvailable {
    func isNextPageAvailable() -> Bool {
        isBluetoothAuthorized && isExplosureNotificationsAuthorized
    }
}

extension OnboardingPermissionsViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        configureBluetoothButton()
        delegate?.permissionsDidChange(onboardingPermissions: self)
    }
}
