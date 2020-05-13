//
//  OnboardingInfoViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification
import UserNotifications

protocol OnboardingInfoViewControllerDelegate: AnyObject {
    func didFinished(onboardingInfoViewController: OnboardingInfoViewController)
}

class OnboardingInfoViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    weak var delegate: OnboardingInfoViewControllerDelegate?

    var onboardingInfo: OnboardingInfo! {
        didSet {
            updateUI()
        }
    }

    // This gives us access to the exposure manager of our parent.
    // We should find a nicer way to get to the manager though.
    private var manager: ExposureManager {
        // swiftlint:disable:next force_cast
        (parent as! OnboardingViewController).manager
    }

    private let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        // should be revised in the future
        viewRespectsSystemMinimumLayoutMargins = false
        view.layoutMargins = .zero
    }

    func run(index: Int) {
        let completion: () -> Void = {
            self.delegate?.didFinished(onboardingInfoViewController: self)
        }
        if index == 1 {
            askLocalNotificationsPermissions(completion: completion)
        } else if index == 2 {
            askExposureNotificationsPermissions(completion: completion)
        } else {
            completion()
        }
    }

    private func updateUI() {
        guard isViewLoaded else { return }
        guard let onboardingInfo = onboardingInfo else { return }
        titleLabel.text = onboardingInfo.title
        imageView.image = UIImage(named: onboardingInfo.imageName)
        textView.text = onboardingInfo.text
    }

    // MARK: Exposure notifications
    private func askExposureNotificationsPermissions(completion: (() -> Void)?) {
        manager.activate { error in
            if let error = error {
                switch error {
                case .exposureNotificationRequired:
                    log(message: "Encourage the user to consider enabling Exposure Notifications.", level: .warning)
                case .exposureNotificationAuthorization:
                    log(message: "Encourage the user to authorize this application", level: .warning)
                }

                completion?()
            } else if let error = error {
                self.showError(error, from: self, completion: completion)
            } else {
                self.manager.enable { enableError in
                    if let enableError = enableError {
                        switch enableError {
                        case .exposureNotificationRequired:
                            log(message: "Encourage the user to consider enabling Exposure Notifications.", level: .warning)
                        case .exposureNotificationAuthorization:
                            log(message: "Encourage the user to authorize this application", level: .warning)
                        }
                    }
                    completion?()
                }
            }
        }
    }

    private func askLocalNotificationsPermissions(completion: (() -> Void)?) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { _, error in
            if let error = error {
                // handle error
                log(message: "Notification authorization request error: \(error.localizedDescription)", level: .error)
            }
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func showError(_ error: ExposureNotificationError, from viewController: UIViewController, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        viewController.present(alert, animated: true, completion: completion)
    }
}
