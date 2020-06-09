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

import Foundation
import UIKit

class ExposureDetectionLongGuideCell: UITableViewCell {
	@IBOutlet private var stackView: UIStackView!

	func configure(image: UIImage?, text: [String]) {
		for subview in stackView.arrangedSubviews {
			stackView.removeArrangedSubview(subview)
			subview.removeFromSuperview()
		}

		if let text = text.first {
			imageView?.image = image
			textLabel?.text = text
		}

		for text in text[1...] {
			let imageView = UIImageView(image: UIImage(named: "Icons_Dot"))
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

			let label = DynamicTypeLabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.text = text
			label.textColor = .enaColor(for: .textPrimary1)
			label.numberOfLines = 0
			label.adjustsFontForContentSizeCategory = true
			label.font = textLabel?.font

			let labelView = UIView()
			labelView.translatesAutoresizingMaskIntoConstraints = false
			labelView.addSubview(label)
			labelView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
			labelView.bottomAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
			labelView.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
			labelView.trailingAnchor.constraint(equalTo: label.trailingAnchor).isActive = true

			let stackView = UIStackView(arrangedSubviews: [imageView, labelView])
			stackView.axis = .horizontal
			stackView.alignment = .center
			stackView.spacing = self.stackView.spacing
			self.stackView.addArrangedSubview(stackView)

			// swiftlint:disable:next force_unwrapping
			imageView.widthAnchor.constraint(equalTo: self.imageView!.widthAnchor).isActive = true

			stackView.setContentHuggingPriority(.required, for: .vertical)
			labelView.setContentHuggingPriority(.required, for: .vertical)
			label.setContentHuggingPriority(.required, for: .vertical)
		}
	}
}
