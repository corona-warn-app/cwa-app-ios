////
// 🦠 Corona-Warn-App
//

import UIKit

class TANInputCell: UITableViewCell, ReuseIdentifierProviding {
	
	var tanInputView: TanInputView!
	
	init(viewModel: TanInputViewModel) {
		super.init(style: .default, reuseIdentifier: TANInputCell.cellIdentifier)

		tanInputView = TanInputView(frame: .zero, viewModel: viewModel)
		tanInputView.isUserInteractionEnabled = true
		tanInputView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(tanInputView)
		
		NSLayoutConstraint.activate([
			tanInputView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
			tanInputView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
			tanInputView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
			tanInputView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
