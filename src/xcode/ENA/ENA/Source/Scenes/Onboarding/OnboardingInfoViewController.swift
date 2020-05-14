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
}

protocol OnboardingInfoViewControllerDelegate: AnyObject {
    func didFinishOnboarding(onboardingInfoViewController: OnboardingInfoViewController)
}

class OnboardingInfoViewController: UIViewController {
	
	var pageType: OnboardingPageType?
	var exposureManager: ExposureManager?
	
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var boldLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var nextButton: UIButton!
	@IBOutlet var pageControl: UIPageControl!
	
    weak var delegate: OnboardingInfoViewControllerDelegate?

	private var onboardingInfos = OnboardingInfo.testData()

    var onboardingInfo: OnboardingInfo! {
        didSet {
            updateUI()
        }
    }

    private let notificationCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
		guard let pageType = pageType else { return }
		onboardingInfo = onboardingInfos[pageType.rawValue]
        configureNextButton()
        updateNextButton()
        // should be revised in the future
        viewRespectsSystemMinimumLayoutMargins = false
        view.layoutMargins = .zero
		runActionForPageType()
    }

    func runActionForPageType() {
        let completion: () -> Void = {
            self.delegate?.didFinishOnboarding(onboardingInfoViewController: self)
        }
		switch pageType {
		case .privacyPage:
			askLocalNotificationsPermissions(completion: completion)
		case .enableLoggingOfContactsPage:
			askExposureNotificationsPermissions(completion: completion)
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
			let aspectRatio	= imageSize.width / imageSize.height
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio, constant: 0.0).isActive = true
		}

		boldLabel.text = onboardingInfo.boldText
		boldLabel.isHidden = onboardingInfo.boldText.isEmpty
		textLabel.text = onboardingInfo.text
		textLabel.isHidden = onboardingInfo.text.isEmpty
		titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
		boldLabel.font = UIFont.boldSystemFont(ofSize: boldLabel.font.pointSize)
		pageControl.numberOfPages = OnboardingPageType.allCases.count
		pageControl.currentPage = pageType?.rawValue ?? 0
		pageControl.currentPageIndicatorTintColor = UIColor.systemGray
		pageControl.pageIndicatorTintColor = UIColor.systemGray4
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
	
    private func configureNextButton() {
        nextButton.setTitleColor(.white, for: .normal)
		nextButton.backgroundColor = UIColor.preferredColor(for: .brandBlue)
        nextButton.layer.cornerRadius = 10.0
        nextButton.layer.masksToBounds = true
    }

    private func updateNextButton() {
		let isLastPage = (pageType == .alwaysStayInformedPage)
        let title = isLastPage ? AppStrings.Onboarding.onboardingFinish : AppStrings.Onboarding.onboardingNext
        nextButton.setTitle(title, for: .normal)
    }

	
    @IBAction func didTapNextButton(_ sender: Any) {
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
