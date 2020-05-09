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

final class OnboardingViewController: UIViewController {

    var manager: ExposureManager?

    private var pages: [OnboardingInfoViewController] = []
    private var onboardingInfos = OnboardingInfo.testData()

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var buttonContainerView: UIView!
    @IBOutlet var pageControl: UIPageControl!

    private var currentIndex: Int = 0
    private lazy var maxIndex: Int = onboardingInfos.count - 1

    override func viewDidLoad() {
        super.viewDidLoad()
        createPages()
        configurePageControl()
        configureNextButton()
        updateNextButton()
    }

    @IBAction func onboardingTapped(_ sender: Any) {
        let vc = pages[currentIndex]
        vc.run(index: currentIndex)
    }

    private func createPages() {
        pages = children.compactMap { $0 as? OnboardingInfoViewController }
        for i in 0..<onboardingInfos.count {
            pages[i].onboardingInfo = onboardingInfos[i]
            pages[i].delegate = self
            pages[i].manager = manager
        }
    }

    private func configurePageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = currentIndex
        pageControl.defersCurrentPageDisplay = true
        pageControl.pageIndicatorTintColor = .separator
        pageControl.currentPageIndicatorTintColor = .label
    }

    private func configureNextButton() {
        nextButton.setTitleColor(.white, for: .normal)
        let image = UIColor.systemIndigo.renderImage()
        nextButton.setBackgroundImage(image, for: .normal)
        nextButton.layer.cornerRadius = 20.0
        nextButton.layer.masksToBounds = true
    }

    private func updateNextButton() {
        let isLastPage = currentIndex == maxIndex
        let title = isLastPage ? AppStrings.Onboarding.onboardingFinish : AppStrings.Onboarding.onboardingNext
        nextButton.setTitle(title, for: .normal)
    }
}

extension OnboardingViewController: OnboardingInfoViewControllerDelegate {

    func didFinished(onboardingInfoViewController: OnboardingInfoViewController) {
        if currentIndex == maxIndex {
            PersistenceManager.shared.isOnboarded = true
            return
        }
        let next = currentIndex + 1
        let point = CGPoint(x: next * Int(scrollView.bounds.width), y: 0)
        currentIndex = next
        pageControl.currentPage = currentIndex
        scrollView.setContentOffset(point, animated: true)
        updateNextButton()
    }
}
