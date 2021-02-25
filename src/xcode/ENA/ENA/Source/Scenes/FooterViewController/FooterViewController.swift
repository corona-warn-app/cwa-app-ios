////
// 🦠 Corona-Warn-App
//

import UIKit

class FooterViewController: UIViewController {

	// MARK: - Init
	init(
		_ viewModel: FooterViewModel,
		didTapPrimaryButton: @escaping () -> Void,
		didTapSecondaryButton: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.didTapPrimaryButton = didTapPrimaryButton
		self.didTapSecondaryButton = didTapSecondaryButton
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPrimaryButton()
		setupSecondaryButton()

		view.insetsLayoutMarginsFromSafeArea = false
		view.preservesSuperviewLayoutMargins = false
		view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		view.addSubview(primaryButton)
		view.addSubview(secondaryButton)

		primaryButton.translatesAutoresizingMaskIntoConstraints = false
		secondaryButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			primaryButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			primaryButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
			primaryButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
			secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: spacing),
			secondaryButton.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
			secondaryButton.widthAnchor.constraint(equalTo: primaryButton.widthAnchor)
		])
	}

	// MARK: - Private

	private let viewModel: FooterViewModel
	private let didTapPrimaryButton: () -> Void
	private let didTapSecondaryButton: () -> Void
	private let spacing: CGFloat = 8

	private let primaryButton: ENAButton = ENAButton(type: .custom)
	private let secondaryButton: ENAButton = ENAButton(type: .custom)

	private func setupPrimaryButton() {
		primaryButton.setTitle(viewModel.primaryButtonName, for: .normal)
		primaryButton.hasBackground = true
		primaryButton.addTarget(self, action: #selector(didHitPrimaryButton), for: .primaryActionTriggered)
		primaryButton.accessibilityIdentifier = AccessibilityIdentifiers.General.primaryFooterButton
	}

	private func setupSecondaryButton() {
		secondaryButton.setTitle(viewModel.secondaryButtonName, for: .normal)
		secondaryButton.hasBackground = true
		secondaryButton.addTarget(self, action: #selector(didHitSecondaryButton), for: .primaryActionTriggered)
		secondaryButton.accessibilityIdentifier = AccessibilityIdentifiers.General.secondaryFooterButton
	}

	@objc
	private func didHitPrimaryButton() {
		didTapPrimaryButton()
	}

	@objc
	private func didHitSecondaryButton() {
		didTapSecondaryButton()
	}
}
