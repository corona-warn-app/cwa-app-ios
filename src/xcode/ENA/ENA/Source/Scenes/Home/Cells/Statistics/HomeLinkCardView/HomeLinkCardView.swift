//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeLinkCardView: UIView {
	
	// MARK: - Overrides
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		setupLayout()
		setupAccessibility()
	}
	
	override var accessibilityElements: [Any]? {
		get {
			var accessibilityElements = [Any?]()
			
			if viewModel?.title != nil {
				titleLabel.accessibilityTraits = .header
				accessibilityElements.append(titleLabel)
			}
			
			if viewModel?.subtitle != nil {
				titleLabel.accessibilityTraits = .staticText
				accessibilityElements.append(subtitleLabel)
			}
			
			infoButton.accessibilityTraits = .button
			accessibilityElements.append(infoButton)
			
			if viewModel?.description != nil {
				descriptionLabel.accessibilityTraits = .staticText
				accessibilityElements.append(descriptionLabel)
			}
			
			if viewModel?.buttonTitle != nil {
				button.accessibilityTraits = .button
				accessibilityElements.append(button)
			}
			
			deleteButton.accessibilityTraits = .button
			accessibilityElements.append(deleteButton)
			
			return accessibilityElements as [Any]
		}
		set {}
	}
	
	// MARK: Internal
	
	func configure(
		viewModel: HomeLinkCardViewModel,
		onInfoButtonTap: @escaping CompletionVoid,
		onDeleteButtonTap: CompletionVoid?,
		onButtonTap: @escaping CompletionURL
	) {
		self.viewModel = viewModel
		
		viewModel.$title
			.sink { [weak self] in
				self?.titleLabel.text = $0
				self?.titleLabel.accessibilityIdentifier = viewModel.titleAccessibilityIdentifier
			}
			.store(in: &subscriptions)
		
		viewModel.$subtitle
			.sink { [weak self] in
				self?.subtitleLabel.text = $0
				self?.subtitleLabel.accessibilityIdentifier = viewModel.subtitleAccessibilityIdentifier
			}
			.store(in: &subscriptions)
		
		viewModel.$description
			.sink { [weak self] in
				self?.descriptionLabel.text = $0
				self?.descriptionLabel.accessibilityIdentifier = viewModel.descriptionAccessibilityIdentifier
			}
			.store(in: &subscriptions)
		
		viewModel.$image
			.sink { [weak self] in
				self?.imageView.image = $0
				self?.imageView.accessibilityIdentifier = viewModel.imageAccessibilityIdentifier
			}
			.store(in: &subscriptions)
		
		viewModel.$buttonTitle
			.sink { [weak self] in
				self?.button.setAttributedTitle($0, for: .normal)
				self?.button.accessibilityIdentifier = viewModel.buttonAccessibilityIdentifier
			}
			.store(in: &subscriptions)
		
		self.onInfoButtonTap = onInfoButtonTap
		self.onDeleteButtonTap = onDeleteButtonTap
		self.onButtonTap = onButtonTap
	}
	
	func set(editMode enabled: Bool, animated: Bool) {
		UIView.animate(withDuration: animated ? 0.3 : 0) {
			if self.deleteButton.isHidden { self.deleteButton.isHidden.toggle() }
			self.deleteButton.alpha = enabled ? 1 : 0
		} completion: { _ in
			self.deleteButton.alpha = enabled ? 1 : 0
		}
	}
	
	// MARK: - Private
	
	@IBOutlet private weak var containerStackView: UIStackView!
	/// Wraps the `descriptionLabel` and the `imageView`
	@IBOutlet private weak var middleStackView: UIStackView!
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var subtitleLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: StackViewLabel!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var button: ENAButton!
	@IBOutlet private weak var infoButton: UIButton!
	@IBOutlet private weak var deleteButton: UIButton!
	
	// Callbacks
	private var onInfoButtonTap: CompletionVoid?
	private var onDeleteButtonTap: CompletionVoid?
	private var onButtonTap: CompletionURL?
	
	private var subscriptions = Set<AnyCancellable>()
	private var viewModel: HomeLinkCardViewModel?
	
	@IBAction private func infoButtonTapped(_ sender: UIButton) {
		onInfoButtonTap?()
	}
	
	@IBAction private func deleteButtonTapped(_ sender: UIButton) {
		onDeleteButtonTap?()
	}
	
	@IBAction private func buttonTapped(_ sender: ENAButton) {
		guard let url = viewModel?.buttonURL else {
			Log.info("Link Card URL was not given.", log: .localStatistics)
			return
		}
		onButtonTap?(url)
	}

	private func setupLayout() {
		// Initial state
		deleteButton.isHidden = true
		
		containerStackView.setCustomSpacing(16, after: middleStackView)
		
		descriptionLabel.style = .subheadline
		descriptionLabel.numberOfLines = 0
		descriptionLabel.font = .enaFont(for: .body)
		descriptionLabel.textColor = .enaColor(for: .textPrimary2)
		
		NSLayoutConstraint.activate([
			button.heightAnchor.constraint(equalToConstant: 50)
		])
	}
	
	private func setupAccessibility() {
		viewModel?.$titleAccessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: titleLabel)
			.store(in: &subscriptions)
		viewModel?.$subtitleAccessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: subtitleLabel)
			.store(in: &subscriptions)
		viewModel?.$descriptionAccessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: descriptionLabel)
			.store(in: &subscriptions)
		viewModel?.$imageAccessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: imageView)
			.store(in: &subscriptions)
		viewModel?.$buttonAccessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: button)
			.store(in: &subscriptions)
		viewModel?.$infoButtonAccessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: infoButton)
			.store(in: &subscriptions)
		viewModel?.$deleteButtonAccessibilityIdentifier
			.assign(to: \.accessibilityIdentifier, on: deleteButton)
			.store(in: &subscriptions)
		
		viewModel?.$titleAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: titleLabel)
			.store(in: &subscriptions)
		viewModel?.$subtitleAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: subtitleLabel)
			.store(in: &subscriptions)
		viewModel?.$descriptionAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: descriptionLabel)
			.store(in: &subscriptions)
		viewModel?.$imageAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: imageView)
			.store(in: &subscriptions)
		viewModel?.$buttonAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: button)
			.store(in: &subscriptions)
		viewModel?.$infoButtonAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: infoButton)
			.store(in: &subscriptions)
		viewModel?.$deleteButtonAccessibilityLabel
			.assign(to: \.accessibilityLabel, on: deleteButton)
			.store(in: &subscriptions)
		
		titleLabel.accessibilityTraits = .header
		subtitleLabel.accessibilityTraits = .staticText
		descriptionLabel.accessibilityTraits = .staticText
		imageView.accessibilityTraits = .image
		button.accessibilityTraits = .button
		infoButton.accessibilityTraits = .button
		deleteButton.accessibilityTraits = .button
	}
}
