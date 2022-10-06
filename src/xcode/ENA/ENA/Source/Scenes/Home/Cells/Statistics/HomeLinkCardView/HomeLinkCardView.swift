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
		onDeleteButtonTap: @escaping CompletionVoid,
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
		
		viewModel.$asset
			.sink { [weak self] in
				self?.assetImageView.image = $0
				self?.assetImageView.accessibilityIdentifier = viewModel.assetAccessibilityIdentifier
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
	@IBOutlet private weak var middleStackView: UIStackView!
	
	@IBOutlet private weak var infoButton: UIButton!
	@IBOutlet private weak var deleteButton: UIButton!
	
	// Content dependent elements
	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var subtitleLabel: ENALabel!
	@IBOutlet private weak var descriptionLabel: StackViewLabel!
	@IBOutlet private weak var assetImageView: UIImageView!
	@IBOutlet private weak var button: ENAButton!
	
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
		
		NSLayoutConstraint.activate([
			button.heightAnchor.constraint(equalToConstant: 50)
		])
	}
}
