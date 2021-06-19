//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewHtmlCell: UITableViewCell {
	let webView = HTMLView()

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setup()
	}

	private func setup() {
		webView.translatesAutoresizingMaskIntoConstraints = false

		contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		contentView.addSubview(webView)
		contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
		contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
		contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: webView.leadingAnchor).isActive = true
		contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: webView.trailingAnchor).isActive = true
	}
}
