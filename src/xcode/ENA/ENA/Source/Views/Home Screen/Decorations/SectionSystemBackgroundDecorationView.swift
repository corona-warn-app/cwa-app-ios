//
// 🦠 Corona-Warn-App
//

import UIKit

class SectionSystemBackgroundDecorationView: UICollectionReusableView {
	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .enaColor(for: .separator)
	}
}
