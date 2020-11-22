//
// 🦠 Corona-Warn-App
//

import UIKit

protocol ConfigurableEuTracingSettingCell: ConfigurableENSettingCell {
	func configure(using viewModel: ENSettingEuTracingViewModel)
}

class EuTracingTableViewCell: UITableViewCell, ConfigurableEuTracingSettingCell {

	@IBOutlet var titleLabel: ENALabel!
	@IBOutlet var countryList: ENALabel!

	weak var delegate: ActionTableViewCellDelegate?

	var state: ENStateHandler.State?
	var viewModel: ENSettingEuTracingViewModel! {
		didSet {
			self.titleLabel.text = viewModel.title
			self.countryList.text = viewModel.countryListLabel
		}
	}

	func configure(using viewModel: ENSettingEuTracingViewModel = .init()) {
		self.viewModel = viewModel
		let backgroundView = UIView()
		backgroundView.backgroundColor = UIColor.clear
		self.selectedBackgroundView = backgroundView
	}

	func configure(for state: ENStateHandler.State) {
		self.state = state
		self.selectionStyle = .none
	}

	func configure(
		for state: ENStateHandler.State,
		delegate: ActionTableViewCellDelegate
	) {
		self.delegate = delegate
		configure(for: state)
	}
}
