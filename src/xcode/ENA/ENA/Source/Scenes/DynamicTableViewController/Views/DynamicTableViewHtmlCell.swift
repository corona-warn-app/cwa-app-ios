//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewHtmlCell: UITableViewCell {
	let textView = HtmlTextView()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	private func setup() {
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.isScrollEnabled = false

		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		contentView.addSubview(textView)
		contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
		contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor).isActive = true
		contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: textView.leadingAnchor).isActive = true
		contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor).isActive = true
	}
}
