//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DynamicTableViewOptionGroupCell: UITableViewCell {

	// MARK: - Internal

	@OpenCombine.Published private(set) var selection: OptionGroupViewModel.Selection?

	func configure(options: [OptionGroupViewModel.Option], initialSelection: OptionGroupViewModel.Selection? = nil) {
		if optionGroupView?.superview != nil {
			optionGroupView.removeFromSuperview()
		}

		let viewModel = OptionGroupViewModel(options: options, initialSelection: initialSelection)
		optionGroupView = OptionGroupView(viewModel: viewModel)
		setUp()

		selectionSubscription = viewModel.$selection.assign(to: \.selection, on: self)
	}

	// MARK: - Private

	private var optionGroupView: OptionGroupView!
	private var selectionSubscription: AnyCancellable?

	private func setUp() {
		selectionStyle = .none
		backgroundColor = .enaColor(for: .background)

		optionGroupView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(optionGroupView)

		NSLayoutConstraint.activate([
			optionGroupView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			optionGroupView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			optionGroupView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
			optionGroupView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}

}
