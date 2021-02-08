//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureDetectionLongGuideCell: UITableViewCell {
	@IBOutlet private var stackView: UIStackView!

	func configure(image: UIImage?, text: [String]) {
		let strings = text.map { NSAttributedString(string: $0) }
		configure(image: image, attributedText: strings)
	}

	func configure(image: UIImage?, attributedText text: [NSAttributedString]) {
		for subview in stackView.arrangedSubviews {
			stackView.removeArrangedSubview(subview)
			subview.removeFromSuperview()
		}

		if let text = text.first {
			imageView?.image = image
			textLabel?.attributedText = text
		}

		for text in text[1...] {
			let imageView = UIImageView(image: UIImage(named: "Icons_Dot"))
			imageView.translatesAutoresizingMaskIntoConstraints = false
			imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

			let label = DynamicTypeLabel()
			label.translatesAutoresizingMaskIntoConstraints = false
			label.attributedText = text
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
