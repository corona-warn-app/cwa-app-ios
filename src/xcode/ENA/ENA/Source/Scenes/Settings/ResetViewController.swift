//
//  ResetViewController.swift
//  ENA
//
//  Created by Steinmetz, Conrad on 14.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import UIKit

protocol ResetDelegate: class {
    func reset()
}

final class ResetViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var header1Label: UILabel!
    @IBOutlet weak var description1TextView: UITextView!
    @IBOutlet weak var resetButton: ENAButton!
    @IBOutlet weak var discardResetButton: UIButton!

    weak var delegate: ResetDelegate?

    @IBAction func resetData(_ sender: Any) {
        delegate?.reset()
    }

    @IBAction func discard(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        setupView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        resetButton.sizeToFit()
        discardResetButton.sizeToFit()
    }

    private func setupView() {
        description1TextView.contentInset = .zero
        description1TextView.textContainer.lineFragmentPadding = 0

        titleLabel.text = AppStrings.ResetView.title
        header1Label.text = AppStrings.ResetView.header1
        description1TextView.text = AppStrings.ResetView.description1
        resetButton.setTitle(AppStrings.ResetView.resetButton, for: .normal)
        resetButton.titleLabel?.adjustsFontForContentSizeCategory = true
        discardResetButton.setTitle(AppStrings.ResetView.discardButton, for: .normal)
        discardResetButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
