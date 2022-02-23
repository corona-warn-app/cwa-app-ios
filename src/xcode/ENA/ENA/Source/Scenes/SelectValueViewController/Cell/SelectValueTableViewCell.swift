////
// 🦠 Corona-Warn-App
//

import UIKit

final class SelectValueTableViewCell: UITableViewCell {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		selectionStyle = .gray

		layoutViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	func configure(_ cellViewModel: SelectValueCellViewModel) {
		selectableValueLabel.text = cellViewModel.text
		selectableValueLabel.isEnabled = cellViewModel.isEnabled
		
		selectableSubtitleLabel.text = cellViewModel.subtitle
		selectableSubtitleLabel.isEnabled = cellViewModel.isEnabled
		selectableSubtitleLabel.isHidden = cellViewModel.subtitle == nil
		isUserInteractionEnabled = cellViewModel.isEnabled
		accessoryView = cellViewModel.isEnabled ? UIImageView(image: cellViewModel.image) : nil
	}


	static var reuseIdentifier: String {
		String(describing: self)
	}
	// MARK: - Private

	private let selectableValueLabel = ENALabel()
	private let selectableSubtitleLabel = ENALabel()
	
	private func layoutViews() {
		backgroundColor = .enaColor(for: .background)
		
		// configure the stackView
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.distribution = .fill
		
		// configure the selectableValueLabel
		selectableValueLabel.translatesAutoresizingMaskIntoConstraints = false
		selectableValueLabel.font = .enaFont(for: .body)
		selectableValueLabel.textAlignment = .left
		selectableValueLabel.numberOfLines = 0

		stackView.addArrangedSubview(selectableValueLabel)
		
		// configure the selectableSubtitleLabel
		selectableSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		selectableSubtitleLabel.font = .enaFont(for: .footnote)
		selectableSubtitleLabel.numberOfLines = 0
		selectableSubtitleLabel.textAlignment = .left
		selectableSubtitleLabel.isHidden = true
		stackView.addArrangedSubview(selectableSubtitleLabel)
		
		contentView.addSubview(stackView)
		
		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0)
		])
		
	}

}
