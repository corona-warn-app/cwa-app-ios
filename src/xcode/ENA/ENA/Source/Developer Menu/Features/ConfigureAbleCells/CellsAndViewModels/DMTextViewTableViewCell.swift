////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMTextViewTableViewCell: UITableViewCell, DMConfigureableCell {

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

	// MARK: - Internal

	func configure<T>(cellViewModel: T) {
		guard let cellViewModel = cellViewModel as? DMTextViewCellViewModel else {
			fatalError("CellViewModel doesn't match expection")
		}

		textView.text = cellViewModel.text
	}

	// MARK: - Private

	private let textView = UITextView()

	private func layoutViews() {
		textView.translatesAutoresizingMaskIntoConstraints = false
		textView.font = .enaFont(for: .headline)
		textView.textAlignment = .center
		textView.isEditable = false

		contentView.addSubview(textView)

		NSLayoutConstraint.activate([
			textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
			textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0),
			textView.topAnchor.constraint(equalTo: contentView.topAnchor),
			textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 45.0)
		])

	}

}
#endif
