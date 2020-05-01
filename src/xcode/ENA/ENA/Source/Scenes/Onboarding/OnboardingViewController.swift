//
//  PageViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

protocol OnboardingNextPageAvailable {
    func isNextPageAvailable() -> Bool
}

class OnboardingViewController: UIViewController {
    
    private var pageViewController: UIPageViewController?
    private var pages: [UIViewController] = []
    private var onboardingInfos = OnboardingInfo.testData()
    private var onboardingPermissions = OnboardingPermissions.testData()
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var buttonContainerView: UIView!
    
    private var currentIndex: Int {
        guard let pageViewController = pageViewController else { return 0 }
        guard let firstViewController = pageViewController.viewControllers?.first else { return 0 }
        guard let index = pages.firstIndex(of: firstViewController) else { return 0 }
        return index
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPages()
        createPageController()
        pageViewController?.dataSource = self
        pageViewController?.delegate = self
        if let firstPage = pages.first {
            pageViewController?.setViewControllers([firstPage], direction: .forward, animated: false)
        }
        updateButton()
    }
    
    private func createPages() {
        pages = onboardingInfos.map { info in
            let infoVC = OnboardingInfoViewController.initiate(for: .onboarding)
            infoVC.onboardingInfo = info
            return infoVC
        }
        let permissionVC = OnboardingPermissionsViewController.initiate(for: .onboarding)
        permissionVC.delegate = self
        permissionVC.onboardingPermissions = onboardingPermissions
        pages.append(permissionVC)
    }
    
    private func createPageController() {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        let pageView = pageViewController.view!
        pageView.translatesAutoresizingMaskIntoConstraints = false
        addChild(pageViewController)
        view.addSubview(pageView)
        let leading = pageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let top = pageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        let trailing = pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let bottom = pageView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: 0)
        NSLayoutConstraint.activate([leading, top, trailing, bottom])
        pageViewController.didMove(toParent: self)
        self.pageViewController = pageViewController
    }
    
    @IBAction func onboardingTapped(_ sender: Any) {
        let isLastPage = currentIndex == pages.count - 1
        if isLastPage {
             UserSettings.onboardingWasShown = true
             let notification = Notification(name: .onboardingFlagDidChange)
             NotificationCenter.default.post(notification)
        } else {
            let nextIndex = currentIndex + 1
            let vc = pages[nextIndex]
            pageViewController?.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            updateButton()
        }
    }
    
    private func updateButton() {
        let isLastPage = currentIndex == pages.count - 1
        let title = isLastPage ? NSLocalizedString("onboarding_button_finish", comment: "") : NSLocalizedString("onboarding_button_next", comment: "")
        nextButton.setTitle(title, for: .normal)
        
        if let onboardingPage = pages[currentIndex] as? OnboardingNextPageAvailable {
            let isNextPageAvailable = onboardingPage.isNextPageAvailable()
            nextButton.isEnabled = isNextPageAvailable
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let next = pages.index(after: index)
        guard next >= 0 && next < pages.count else { return nil }
        return pages[next]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previous = pages.index(before: index)
        guard previous >= 0 && previous < pages.count else { return nil }
        return pages[previous]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        currentIndex
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updateButton()
    }
}

extension OnboardingViewController: OnboardingPermissionsViewControllerDelegate {
    func permissionsDidChange(onboardingPermissions: OnboardingPermissionsViewController) {
        updateButton()
    }
}
