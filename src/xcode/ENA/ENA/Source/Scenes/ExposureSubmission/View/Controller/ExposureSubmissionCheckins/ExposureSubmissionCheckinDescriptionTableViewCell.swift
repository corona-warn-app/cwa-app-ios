////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionCheckinDescriptionTableViewCell: UITableViewCell, ReuseIdentifierProviding {


	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		contentView.addSubview(descriptionLabel)
		NSLayoutConstraint.activate([
			descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
		])
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let cellModel = ExposureSubmissionCheckinDescriptionCellModel()
	private lazy var descriptionLabel: ENALabel = {
		let label = ENALabel()
		label.style = .body
		label.text = cellModel.description
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

}
