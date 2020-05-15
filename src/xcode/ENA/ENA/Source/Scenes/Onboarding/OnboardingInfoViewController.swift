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

enum OnboardingPageType: Int, CaseIterable {
	case togetherAgainstCoronaPage = 0
	case privacyPage = 1
	case enableLoggingOfContactsPage = 2
	case howDoesDataExchangeWorkPage = 3
	case alwaysStayInformedPage = 4
	
	func next() -> OnboardingPageType? {
		return OnboardingPageType(rawValue: self.rawValue + 1)
	}
	func isLast() -> Bool {
		return (self == OnboardingPageType.allCases.last)
	}
}

class OnboardingInfoViewController: UIViewController {
	
	var pageType: OnboardingPageType?
	var exposureManager: ExposureManager?
	
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var boldLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
	@IBOutlet var ignoreButton: UIButton!
	
	private var onboardingInfos = OnboardingInfo.testData()

    var onboardingInfo: OnboardingInfo?

    private let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let pageType = pageType else { return }
		onboardingInfo = onboardingInfos[pageType.rawValue]
        // should be revised in the future
        viewRespectsSystemMinimumLayoutMargins = false
        view.layoutMargins = .zero
		updateUI()
    }

    func runActionForPageType(completion: @escaping () -> Void) {
		switch pageType {
		case .enableLoggingOfContactsPage:
			askExposureNotificationsPermissions(completion: completion)
		case .alwaysStayInformedPage:
			askLocalNotificationsPermissions(completion: completion)
		default:
			completion()
		}
    }

    private func updateUI() {
        guard isViewLoaded else { return }
        guard let onboardingInfo = onboardingInfo else { return }

        titleLabel.text = onboardingInfo.title

        imageView.image = UIImage(named: onboardingInfo.imageName)
        if let imageSize = imageView.image?.size {
            let aspectRatio = imageSize.width / imageSize.height
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio, constant: 0.0).isActive = true
        }

        boldLabel.text = onboardingInfo.boldText
        boldLabel.isHidden = onboardingInfo.boldText.isEmpty

        textLabel.text = onboardingInfo.text
        textLabel.isHidden = onboardingInfo.text.isEmpty

		nextButton.setTitle(onboardingInfo.actionText, for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
		nextButton.backgroundColor = UIColor.preferredColor(for: .tintColor)
        nextButton.layer.cornerRadius = 10.0
        nextButton.layer.masksToBounds = true
		nextButton.isHidden = onboardingInfo.actionText.isEmpty
		
		ignoreButton.setTitle(onboardingInfo.ignoreText, for: .normal)
        ignoreButton.setTitleColor(UIColor.preferredColor(for: .onboardingButton), for: .normal)
		ignoreButton.backgroundColor = UIColor.clear
		ignoreButton.isHidden = onboardingInfo.ignoreText.isEmpty
		
		titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
		boldLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
		textLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
		
		let insetPadding: CGFloat = 16
		nextButton.contentEdgeInsets = UIEdgeInsets(top: insetPadding, left: 0, bottom: insetPadding, right: 0)
		nextButton.titleEdgeInsets = UIEdgeInsets(top: insetPadding, left: 0, bottom: insetPadding, right: 0)
		ignoreButton.contentEdgeInsets = UIEdgeInsets(top: insetPadding, left: 0, bottom: insetPadding, right: 0)
		ignoreButton.titleEdgeInsets = UIEdgeInsets(top: insetPadding, left: 0, bottom: insetPadding, right: 0)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
			// content size has changed
			titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
			boldLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
			textLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
		}
	}
	
	
    // MARK: Exposure notifications
    private func askExposureNotificationsPermissions(completion: (() -> Void)?) {
		guard let exposureManager = exposureManager else { fatalError("Should have an instance of exposureManager here") }
        exposureManager.activate { error in
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
                exposureManager.enable { enableError in
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
	
    @IBAction func didTapNextButton(_ sender: Any) {
		runActionForPageType(completion: {
			self.gotoNextScreen()
		})
    }

    @IBAction func didTapIgnoreButton(_ sender: Any) {
		gotoNextScreen()
    }

	func gotoNextScreen() {
		guard let nextPageType = pageType?.next() else {
            PersistenceManager.shared.isOnboarded = true
			return
		}
        let vc = OnboardingInfoViewController.initiate(for: .onboarding)
		vc.pageType = nextPageType
		vc.exposureManager = exposureManager
		navigationController?.pushViewController(vc, animated: true)
	}
	
}
