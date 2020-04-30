//
//  PageViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    private var pageViewController: UIPageViewController?
    private var pages: [UIViewController] = []
    private var infos = OnboardingInfo.testData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createPages()
        createPageController()
        pageViewController?.dataSource = self
        if let firstPage = pages.first {
            pageViewController?.setViewControllers([firstPage], direction: .forward, animated: false)
        }
        
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
        let top = pageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -20)
        let trailing = pageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let bottom = pageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
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

extension PageViewController: UIPageViewControllerDataSource {
    
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
