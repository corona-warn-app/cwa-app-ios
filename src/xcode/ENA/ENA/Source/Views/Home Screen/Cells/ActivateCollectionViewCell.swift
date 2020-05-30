// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import UIKit

class ActivateCollectionViewCell: HomeCardCollectionViewCell {
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var chevronImageView: UIImageView!
    @IBOutlet var viewContainer: UIView!
    @IBOutlet var constraint: NSLayoutConstraint!

    private let iconTitleDistance: CGFloat = 10.0

    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextView.textContainerInset = .zero
        titleTextView.textContainer.lineFragmentPadding = 0
        titleTextView.isUserInteractionEnabled = false
        let containerInsets = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        viewContainer.layoutMargins = containerInsets
        wrapImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        wrapImage()
    }

    private func wrapImage() {
        guard let lineHeight = titleTextView.font?.lineHeight else { return }

        var iconImageFrame = convert(iconImageView.frame, to: titleTextView)
        let lineHeightRounded = lineHeight
        let offset: CGFloat = (lineHeightRounded - iconImageFrame.height) / 2.0

        constraint.constant = max(offset.rounded(), 0)

        iconImageFrame.size = CGSize(width: iconImageFrame.width + iconTitleDistance, height: iconImageFrame.height)
        let bezierPath = UIBezierPath(rect: iconImageFrame)
        titleTextView.textContainer.exclusionPaths = [bezierPath]
    }
}
