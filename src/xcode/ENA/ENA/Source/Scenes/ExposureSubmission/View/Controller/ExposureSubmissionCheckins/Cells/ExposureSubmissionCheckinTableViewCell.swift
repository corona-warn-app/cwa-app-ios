////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionCheckinTableViewCell: UITableViewCell, ReuseIdentifierProviding {

	// MARK: - Init
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func prepareForReuse() {
		super.prepareForReuse()
		containerView.backgroundColor = .enaColor(for: .cellBackground)
		cellModel = nil
		subscriptions = []
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		if highlighted {
			containerView.backgroundColor = .enaColor(for: .listHighlight)
		} else {
			containerView.backgroundColor = .enaColor(for: .cellBackground)
		}
	}
	
	// MARK: - Internal
	
	func configure(with cellModel: ExposureSubmissionCheckinCellModel) {
		self.cellModel = cellModel
		
		descriptionLabel.text = cellModel.description
		addressLabel.text = cellModel.address
		dateIntervalLabel.text = cellModel.dateInterval
		
		cellModel.$checkmarkImage
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.image, on: checkmarkImageView)
			.store(in: &subscriptions)

		cellModel.$cellIsSelected
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isSelected, on: self)
			.store(in: &subscriptions)
	}
	
	// MARK: - Private
	
	private var cellModel: ExposureSubmissionCheckinCellModel!

	private let containerView = UIView()
	private let checkmarkImageView = UIImageView()
	private let descriptionLabel = ENALabel()
	private let addressLabel = ENALabel()
	private let dateIntervalLabel = ENALabel()
	private var subscriptions: Set<AnyCancellable> = []

	private func setupView() {
		selectionStyle = .none
		
		backgroundColor = .clear
		contentView.backgroundColor = .clear
		
		checkmarkImageView.contentMode = .scaleAspectFit
		checkmarkImageView.setContentHuggingPriority(.required, for: .horizontal)
		
		descriptionLabel.style = .headline
		descriptionLabel.numberOfLines = 0
		descriptionLabel.textColor = .enaColor(for: .textPrimary1)
		
		addressLabel.style = .body
		addressLabel.numberOfLines = 0
		addressLabel.textColor = .enaColor(for: .textPrimary2)

		dateIntervalLabel.style = .body
		dateIntervalLabel.numberOfLines = 0
		dateIntervalLabel.textColor = .enaColor(for: .textPrimary1)
		
		contentView.addSubview(containerView)
		containerView.backgroundColor = .enaColor(for: .cellBackground)
		
		let textStackView = UIStackView(arrangedSubviews: [descriptionLabel, addressLabel, dateIntervalLabel])
		textStackView.axis = .vertical
		textStackView.spacing = 4
		
		let stackView = UIStackView(arrangedSubviews: [checkmarkImageView, textStackView])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .horizontal
		stackView.alignment = .top
		stackView.spacing = 13
		
		containerView.addSubview(stackView)
		
		containerView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			
			checkmarkImageView.heightAnchor.constraint(equalToConstant: 34),
			checkmarkImageView.widthAnchor.constraint(equalToConstant: 34),
			
			
			stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
			stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 13),
			stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
			stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -13)
		])
		
		containerView.layer.cornerRadius = 14
		if #available(iOS 13.0, *) {
			containerView.layer.cornerCurve = .continuous
		}
	}
	
}
