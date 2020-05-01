//
//  OnboardingPermissionsViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 01.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol OnboardingPermissionsViewControllerDelegate: AnyObject {
    func permissionsDidChange(onboardingPermissions: OnboardingPermissionsViewController)
}

class OnboardingPermissionsViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var bluetoothLabel: UILabel!
    @IBOutlet private var bluetoothButton: UIButton!

    @IBOutlet private var notificationLabel: UILabel!
    
    private var centralManager: CBCentralManager!
    
    private var isBluetoothAuthorized: Bool {
        CBCentralManager.authorization == .allowedAlways
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
    
    private func updateUI() {
        guard isViewLoaded else { return }
        titleLabel.text = onboardingPermissions.title
        imageView.image = UIImage(named: onboardingPermissions.imageName)
        
        bluetoothLabel.text = onboardingPermissions.bluetoothTitle
        notificationLabel.text = onboardingPermissions.notificationsTitle
        
        configureBluetoothButton()
    }
    
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
}
 
extension OnboardingPermissionsViewController: OnboardingNextPageAvailable {
    func isNextPageAvailable() -> Bool {
        let isNotificationsAvailable = true
        return isBluetoothAuthorized && isNotificationsAvailable
    }
}

extension OnboardingPermissionsViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        configureBluetoothButton()
        delegate?.permissionsDidChange(onboardingPermissions: self)
    }
}
