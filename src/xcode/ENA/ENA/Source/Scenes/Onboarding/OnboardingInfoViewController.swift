//
//  OnboardingInfoViewController.swift
//  ENA
//
//  Created by Tikhonov, Aleksandr on 30.04.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class OnboardingInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textView: UITextView!
    
    var onboardingInfo: OnboardingInfo? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        guard isViewLoaded else { return }
        titleLabel.text = onboardingInfo?.title
        if let imageName = onboardingInfo?.imageName {
            imageView.image = UIImage(named: imageName)
        } else {
            imageView.image = nil
        }
        textView.text = onboardingInfo?.text
    }
    
}
