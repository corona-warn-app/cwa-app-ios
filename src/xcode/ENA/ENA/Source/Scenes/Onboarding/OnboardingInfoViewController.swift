//
//  OnboardingInfoViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit
import ExposureNotification

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        // should be revised in the future
        viewRespectsSystemMinimumLayoutMargins = false
        view.layoutMargins = .zero
    }
    
    func run(index: Int) {
        let closure: () -> Void = {
            self.delegate?.didFinished(onboardingInfoViewController: self)
        }
        if index == 2 {
            askExposureNotificationsPermissions(completion: closure)
        } else {
            closure()
        }
    }
    
    private func updateUI() {
        guard isViewLoaded else { return }
        guard let onboardingInfo = onboardingInfo else { return }
        // here is big onboarding text, should it be translated?
        // TODO: localize
        titleLabel.text = onboardingInfo.title
        imageView.image = UIImage(named: onboardingInfo.imageName)
        textView.text = onboardingInfo.text
    }
    
    
    // MARK: Exposure notifications
    
    private func askExposureNotificationsPermissions(completion: (() -> Void)?) {
        // still in the development
        let manager = ExposureManager()
        manager.activate { error in
            if let error = error as? ENError, error.code == .notAuthorized {
                print("Encourage the user to consider enabling Exposure Notifications.")
                completion?()
            } else if let error = error {
                self.showError(error, from: self, completion: completion)
            } else {
                completion?()
            }
        }
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func showError(_ error: Error, from viewController: UIViewController, completion: (() -> Void)?) {
        let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        viewController.present(alert, animated: true, completion: completion)
    }
}
