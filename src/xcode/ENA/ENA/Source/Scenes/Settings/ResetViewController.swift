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
    @IBOutlet weak var header1Label: UILabel!
    @IBOutlet weak var description1TextView: UITextView!
    @IBOutlet weak var resetButton: ENAButton!
    @IBOutlet weak var discardResetButton: UIButton!

    weak var delegate: ResetDelegate?

    @IBAction func resetData(_ sender: Any) {
        delegate?.reset()
    }

    override func viewDidLoad() {
        setupView()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        resetButton.sizeToFit()
        discardResetButton.sizeToFit()
    }

    private func setupView() {
        navigationItem.title = AppStrings.Reset.navigationBarTitle

        description1TextView.contentInset = .zero
        description1TextView.textContainer.lineFragmentPadding = 0

        header1Label.text = AppStrings.Reset.header1
        description1TextView.text = AppStrings.Reset.description1
        resetButton.setTitle(AppStrings.Reset.resetButton, for: .normal)
        resetButton.titleLabel?.adjustsFontForContentSizeCategory = true
        discardResetButton.setTitle(AppStrings.Reset.discardButton, for: .normal)
        discardResetButton.titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
