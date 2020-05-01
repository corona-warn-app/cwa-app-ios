//
//  PageViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    private var pageViewController: UIPageViewController?
    private var pages: [UIViewController] = []
    private var infos = OnboardingInfo.testData()
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var buttonContainerView: UIView!
    
    @IBAction func onboardingTapped(_ sender: Any) {
        
        print(currentIndex)
        let nextIndex = currentIndex + 1
        guard nextIndex >= 0 && nextIndex < pages.count else { return }
        let vc = pages[nextIndex]
        pageViewController?.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        updateButton()
        // UserSettings.onboardingWasShown = true
        // let notification = Notification(name: .onboardingFlagDidChange)
        // NotificationCenter.default.post(notification)
    }
    
    private func updateButton() {
        let isLastPage = currentIndex == pages.count - 1
        let title = isLastPage ? "Finish" : "Next"
        nextButton.setTitle(title, for: .normal)
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
        pages = infos.map { info in
            let vc = OnboardingInfoViewController.initiate(for: .onboarding)
            vc.onboardingInfo = info
            return vc
        }
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
    
    private var currentIndex: Int {
        guard let pageViewController = pageViewController else { return 0 }
        guard let firstViewController = pageViewController.viewControllers?.first else { return 0 }
        guard let index = pages.firstIndex(of: firstViewController) else { return 0 }
        return index
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
