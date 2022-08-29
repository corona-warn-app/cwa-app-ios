//
// 🦠 Corona-Warn-App
//

import UIKit

class MaskStateTableViewCell: UITableViewCell, UITextViewDelegate, ReuseIdentifierProviding {
	
	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		setupView()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Protocol UITextViewDelegate

	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.open(url: url, interaction: interaction) == .allow
	}
	
	// MARK: - Private
	
	private let backgroundContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = .enaColor(for: .cellBackground2)
		view.layer.borderColor = .enaColor(for: .hairline)
		if #available(iOS 13.0, *) {
			view.layer.cornerCurve = .continuous
		}
		view.layer.cornerRadius = 15
		view.layer.masksToBounds = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		selectionStyle = .none
		
		contentView.addSubview(backgroundContainerView)
		
		NSLayoutConstraint.activate([
			backgroundContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			backgroundContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			backgroundContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			backgroundContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			backgroundContainerView.heightAnchor.constraint(equalToConstant: 200) // TODO: Remove, just for test
		])
	}
}
