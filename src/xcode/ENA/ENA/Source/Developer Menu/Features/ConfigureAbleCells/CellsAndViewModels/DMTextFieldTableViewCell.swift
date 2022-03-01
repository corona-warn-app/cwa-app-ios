////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMTextFieldTableViewCell: UITableViewCell, ConfigureableCell, UITextFieldDelegate {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .none
		layoutViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Protocol ConfigureableCell

	func configure<T>(cellViewModel: T) {
		guard let cellViewModel = cellViewModel as? DMTextFieldCellViewModel else {
			fatalError("CellViewModel doesn't match expectations")
		}
		label.text = cellViewModel.labelText
		viewModel = cellViewModel
	}

	// MARK: - Protocol TextFieldDelegate

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		viewModel?.textFieldDidChange(string)
		return true
	}

	// MARK: - Private

	private let label = UILabel()
	private let inputTextField = UITextField()

	private var viewModel: DMTextFieldCellViewModel?

	private func layoutViews() {
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .enaFont(for: .body)
		label.numberOfLines = 0
		label.textAlignment = .left

		inputTextField.translatesAutoresizingMaskIntoConstraints = false
		inputTextField.delegate = self
		inputTextField.font = .enaFont(for: .body)
		inputTextField.borderStyle = .roundedRect
		inputTextField.keyboardType = .numberPad

		let stackView = UIStackView(arrangedSubviews: [label, inputTextField])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .fill
		stackView.axis = .vertical
		stackView.distribution = .fillProportionally

		contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60.0)
		])
	}

}

#endif
