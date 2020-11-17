//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DynamicTableViewHeaderFooterView: UITableViewHeaderFooterView {
	private let tapGestureRecognizer = DynamicTableHeaderFooterViewTapGestureRecognizer()

	var block: (() -> Void)? {
		get { tapGestureRecognizer.block }
		set { tapGestureRecognizer.block = newValue }
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		gestureRecognizers = [tapGestureRecognizer]
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		tapGestureRecognizer.block = nil
	}
}

private class DynamicTableHeaderFooterViewTapGestureRecognizer: UITapGestureRecognizer {
	var block: (() -> Void)?

	init() {
		super.init(target: nil, action: nil)
		addTarget(self, action: #selector(didTap))
	}

	@objc
	private func didTap() {
		block?()
	}
}
