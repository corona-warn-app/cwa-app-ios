////
// 🦠 Corona-Warn-App
//

import UIKit

class TANInputCell: UITableViewCell, ReuseIdentifierProviding {
	
	var tanInputView: TanInputView!
	
	init(viewModel: TanInputViewModel) {
		super.init(style: .default, reuseIdentifier: TANInputCell.cellIdentifier)

		let descriptionLabel = ENALabel()
		descriptionLabel.style = .headline
		descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.textColor = .enaColor(for: .textPrimary1)
		descriptionLabel.numberOfLines = 0
		contentView.addSubview(descriptionLabel)
		
		tanInputView = TanInputView(frame: .zero, viewModel: viewModel)
		tanInputView.isUserInteractionEnabled = true
		tanInputView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(tanInputView)
		
		NSLayoutConstraint.activate([
			
			descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
			
			tanInputView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			tanInputView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			tanInputView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 18),
			tanInputView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
