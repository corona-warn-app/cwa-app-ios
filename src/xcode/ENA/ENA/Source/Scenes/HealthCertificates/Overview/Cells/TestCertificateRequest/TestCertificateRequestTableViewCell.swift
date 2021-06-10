////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TestCertificateRequestTableViewCell: UITableViewCell, ReuseIdentifierProviding {
	
	// MARK: - Overrides

	override func awakeFromNib() {
		super.awakeFromNib()

		accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Overview.testCertificateRequestCell

		titleLabel.accessibilityTraits = [.header]
		updateActivityIndicatorStyle()
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		subscriptions = []
		cellModel = nil
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		updateActivityIndicatorStyle()
	}

	// MARK: - Internal

	func configure(
		with cellModel: TestCertificateRequestCellModel,
		onTryAgainButtonTap: @escaping () -> Void,
		onRemoveButtonTap: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		titleLabel.text = cellModel.title

		subtitleLabel.text = cellModel.subtitle

		cellModel.$subtitle
			.dropFirst() // First state is set manually above without calling onUpdate() to prevent initial animation, especially on reuse
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.subtitleLabel.text = $0
				self?.updateAccessibilityElements()
				onUpdate()
			}
			.store(in: &subscriptions)

		registrationDateLabel.text = cellModel.registrationDate

		loadingStateLabel.text = cellModel.loadingStateDescription
		loadingStateStackView.isHidden = cellModel.isLoadingStateHidden
		loadingActivityIndicator.startAnimating()

		cellModel.$isLoadingStateHidden
			.dropFirst() // First state is set manually above without calling onUpdate() to prevent initial animation, especially on reuse
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.loadingStateStackView.isHidden = $0
				self?.loadingActivityIndicator.startAnimating()
				self?.updateAccessibilityElements()
				onUpdate()
			}
			.store(in: &subscriptions)

		tryAgainButton.setTitle(cellModel.tryAgainButtonTitle, for: .normal)
		removeButton.setTitle(cellModel.removeButtonTitle, for: .normal)

		buttonsStackView.isHidden = cellModel.buttonsHidden

		cellModel.$buttonsHidden
			.dropFirst() // First state is set manually above without calling onUpdate() to prevent initial animation, especially on reuse
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] in
				self?.buttonsStackView.isHidden = $0
				self?.updateAccessibilityElements()
				onUpdate()
			}
			.store(in: &subscriptions)

		updateAccessibilityElements()

		self.cellModel = cellModel
		self.onTryAgainButtonTap = onTryAgainButtonTap
		self.onRemoveButtonTap = onRemoveButtonTap
	}
	
	// MARK: - Private

	private var cellModel: TestCertificateRequestCellModel?
	private var onTryAgainButtonTap: (() -> Void)?
	private var onRemoveButtonTap: (() -> Void)?
	private var subscriptions = Set<AnyCancellable>()

	@IBOutlet private weak var titleLabel: ENALabel!
	@IBOutlet private weak var subtitleLabel: ENALabel!
	@IBOutlet private weak var registrationDateLabel: ENALabel!

	@IBOutlet private weak var loadingStateStackView: UIStackView!
	@IBOutlet private weak var loadingActivityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var loadingStateLabel: ENALabel!

	@IBOutlet private weak var buttonsStackView: UIStackView!
	@IBOutlet private weak var tryAgainButton: ENAButton!
	@IBOutlet private weak var removeButton: ENAButton!

	@IBOutlet private weak var containerView: CardView!

	@IBAction private func didTapTryAgainButton(_ sender: Any) {
		onTryAgainButtonTap?()
	}

	@IBAction func removeButtonTapped(_ sender: Any) {
		onRemoveButtonTap?()
	}

	private func updateActivityIndicatorStyle() {
		loadingActivityIndicator.style = traitCollection.userInterfaceStyle == .dark ? .white : .gray
	}

	private func updateAccessibilityElements() {
		guard let cellModel = cellModel else {
			return
		}

		containerView.accessibilityElements = [titleLabel as Any, subtitleLabel as Any, registrationDateLabel as Any]

		if !cellModel.isLoadingStateHidden {
			containerView.accessibilityElements?.append(loadingStateLabel as Any)
		}

		if !cellModel.buttonsHidden {
			containerView.accessibilityElements?.append(tryAgainButton as Any)
			containerView.accessibilityElements?.append(removeButton as Any)
		}
	}

}
