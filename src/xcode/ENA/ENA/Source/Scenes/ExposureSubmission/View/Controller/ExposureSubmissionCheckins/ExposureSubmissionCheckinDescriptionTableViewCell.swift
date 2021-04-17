////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionCheckinDescriptionTableViewCell: UITableViewCell, ReuseIdentifierProviding {


	// MARK: - Init
	
	// MARK: - Overrides
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		contentView.addSubview(descriptionLabel)
		NSLayoutConstraint.activate([
			descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16),
			descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8)
		])
	}
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let cellModel = ExposureSubmissionCheckinDescriptionCellModel()
	private lazy var descriptionLabel: ENALabel = {
		let label = ENALabel()
		label.style = .body
		label.textColor = .enaColor(for: .textPrimary1)
		label.text = cellModel.description
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

}
