//
//  SettingsTableViewCell.swift
//  ENA
//
//  Created by Zildzic, Adnan on 20.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import UIKit

class MainSettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var imageContainer: UIView!

    @IBOutlet weak var descriptionLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageContainerFirstBaselineConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageContainerCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var stateLabelLeading: NSLayoutConstraint!
    @IBOutlet weak var stateLabelTop: NSLayoutConstraint!
    @IBOutlet weak var stateLabelLeadingLarge: NSLayoutConstraint!
    @IBOutlet weak var stateLabelTopLarge: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var disclosureIndicatorLeading: NSLayoutConstraint!
    @IBOutlet weak var disclosureIndicatorLeadingLarge: NSLayoutConstraint!

    private var regularConstraints: [NSLayoutConstraint] = []
    private var largeTextConstraints: [NSLayoutConstraint] = []

    private let labelPadding: CGFloat = 10

    override func awakeFromNib() {
        super.awakeFromNib()

        setLayoutConstraints()
    }

    func configure(model: SettingsViewModel.Main) {
        let icon = model.icon

        iconImageView.image = icon.isSystem ? UIImage(systemName: icon.imageName) : UIImage(named: icon.imageName)
        stateLabel.text = model.state ?? model.stateInactive

        updateDescriptionLabel(model.description)
        updateLayoutConstraints()
    }

    private func setLayoutConstraints() {
        regularConstraints = [ imageContainerCenterConstraint, descriptionLabelTrailingConstraint, descriptionLabelBottom, stateLabelLeading, stateLabelTop, disclosureIndicatorLeading ]

        let labelHalfCapHeight = descriptionLabel.font.capHeight / 2
        imageContainerFirstBaselineConstraint.constant = labelHalfCapHeight

        largeTextConstraints = [ descriptionLabelLeadingConstraint, imageContainerFirstBaselineConstraint, stateLabelTopLarge, stateLabelLeadingLarge, disclosureIndicatorLeadingLarge ]
    }

    private func updateLayoutConstraints() {
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            NSLayoutConstraint.deactivate(regularConstraints)
            NSLayoutConstraint.activate(largeTextConstraints)
        } else {
            NSLayoutConstraint.deactivate(largeTextConstraints)
            NSLayoutConstraint.activate(regularConstraints)
        }
    }

    private func updateDescriptionLabel(_ value: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.setParagraphStyle(NSParagraphStyle.default)

        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            paragraphStyle.firstLineHeadIndent = imageContainer.frame.size.width + labelPadding
        }

        let attributedString = NSAttributedString(string: value,
                                                  attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle,
                                                               NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)])
        descriptionLabel.attributedText = attributedString
    }
}
