////
// 🦠 Corona-Warn-App
//
#if !RELEASE

import UIKit

class DMKeyValueTableViewCell: UITableViewCell, ConfigureAbleCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		layoutViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	// MARK: - Internal

	func configure<T>(cellViewModel: T) {
		guard let cellViewModel = cellViewModel as? DMKeyValueCellViewModel else {
			fatalError("CellViewModel doesn't macht expectations")
		}
		keyLabel.text = cellViewModel.key
		valueLabel.text = cellViewModel.value
	}

	// MARK: - Private

	private let keyLabel = UILabel()
	private let valueLabel = UILabel()

	private func layoutViews() {
		keyLabel.translatesAutoresizingMaskIntoConstraints = false
		keyLabel.font = .enaFont(for: .subheadline)
		keyLabel.numberOfLines = 0

		valueLabel.translatesAutoresizingMaskIntoConstraints = false
		valueLabel.font = .enaFont(for: .subheadline)
		valueLabel.numberOfLines = 0

		let stackView = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .fill
		stackView.axis = .horizontal

		contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 20.0),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 45.0)
		])

	}

}

#endif
