////
// 🦠 Corona-Warn-App
//

import UIKit

class TANErrorCell: UITableViewCell, ReuseIdentifierProviding {
   
   var errorLabel: ENALabel!
   
   override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
	   super.init(style: style, reuseIdentifier: reuseIdentifier)
	   
	   errorLabel = ENALabel()
	   errorLabel.style = .headline
	   errorLabel.text = ""
	   errorLabel.translatesAutoresizingMaskIntoConstraints = false
	   errorLabel.textColor = .enaColor(for: .textSemanticRed)
	   errorLabel.numberOfLines = 0
	   contentView.addSubview(errorLabel)
	   
	   NSLayoutConstraint.activate([
		   errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
		   errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
		   errorLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
		   errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
	   ])
   }
   
   required init?(coder: NSCoder) {
	   fatalError("init(coder:) has not been implemented")
   }
}
