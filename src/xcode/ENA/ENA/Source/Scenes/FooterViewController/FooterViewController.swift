////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

/**
	If the ViewController and the FooterViewController are composed inside a TopBottomContainer,
	ViewController that implement this protocol get called if a button gets tapped in the footerViewController
*/
protocol FooterViewHandling {
	var footerView: FooterViewUpdating? { get }

	func didShowKeyboard(_ size: CGRect)
	func didHideKeyboard()
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType)
}

extension FooterViewHandling where Self: UIViewController {
	var footerView: FooterViewUpdating? {
		return parent as? FooterViewUpdating
	}

	func didShowKeyboard(_ size: CGRect) {}
	func didHideKeyboard() {}
}

class FooterViewController: UIViewController {

	// MARK: - Init
	init(
		_ viewModel: FooterViewModel,
		didTapPrimaryButton: @escaping () -> Void = {},
		didTapSecondaryButton: @escaping () -> Void = {}
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
		
		buttonsStackView = UIStackView()
		buttonsStackView.alignment = .fill
		buttonsStackView.axis = .vertical
		buttonsStackView.distribution = .fill
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(buttonsStackView)

		primaryButton.disabledBackgroundColor = viewModel.primaryCustomDisableBackgroundColor
		primaryButton.hasBackground = true
		primaryButton.addTarget(self, action: #selector(didHitPrimaryButton), for: .primaryActionTriggered)
		primaryButton.translatesAutoresizingMaskIntoConstraints = false
		buttonsStackView.addArrangedSubview(primaryButton)
		
		primaryButtonHeightConstraint = primaryButton.heightAnchor.constraint(equalToConstant: viewModel.buttonHeight)
		primaryButtonHeightConstraint.priority = .defaultHigh
		
		secondaryButton.disabledBackgroundColor = viewModel.secondaryCustomDisableBackgroundColor
		secondaryButton.hasBackground = true
		secondaryButton.addTarget(self, action: #selector(didHitSecondaryButton), for: .primaryActionTriggered)
		secondaryButton.translatesAutoresizingMaskIntoConstraints = false
		buttonsStackView.addArrangedSubview(secondaryButton)
		
		secondaryButtonHeightConstraint = secondaryButton.heightAnchor.constraint(equalToConstant: viewModel.buttonHeight)
		secondaryButtonHeightConstraint.priority = .defaultHigh

		topInsetConstraint = buttonsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: viewModel.topBottomInset)
		bottomInsetConstraint = buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -viewModel.topBottomInset)
		
		NSLayoutConstraint.activate([
			// buttonsStackView
			topInsetConstraint,
			bottomInsetConstraint,
			buttonsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: viewModel.leftRightInset),
			buttonsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -viewModel.leftRightInset),
			// primaryButton
			primaryButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor),
			primaryButtonHeightConstraint,
			// secondaryButton
			secondaryButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor),
			secondaryButtonHeightConstraint
		])

		updateViewModel()
	}

	// MARK: - Internal

	var viewModel: FooterViewModel {
		didSet {
			updateViewModel()
		}
	}

	// MARK: - Private

	private let didTapPrimaryButton: () -> Void
	private let didTapSecondaryButton: () -> Void

	private let primaryButton: ENAButton = ENAButton(type: .custom)
	private let secondaryButton: ENAButton = ENAButton(type: .custom)

	private var buttonsStackView: UIStackView!
	private var primaryButtonHeightConstraint: NSLayoutConstraint!
	private var secondaryButtonHeightConstraint: NSLayoutConstraint!
	private var topInsetConstraint: NSLayoutConstraint!
	private var bottomInsetConstraint: NSLayoutConstraint!
	private var subscription: [AnyCancellable] = []

	@objc
	private func didHitPrimaryButton() {
		guard let footerViewHandler = (parent as? FooterViewUpdating)?.footerViewHandler else {
			didTapPrimaryButton()
			return
		}
		footerViewHandler.didTapFooterViewButton(.primary)
	}

	@objc
	private func didHitSecondaryButton() {
		guard let footerViewHandler = (parent as? FooterViewUpdating)?.footerViewHandler else {
			didTapSecondaryButton()
			return
		}
		footerViewHandler.didTapFooterViewButton(.secondary)
	}
	
	private func updateViewModel() {
		
		// clear and reset
		
		subscription.forEach { $0.cancel() }
		subscription.removeAll()
		
		// hiding these views will force the stack view to update its layout
		primaryButton.isHidden = true
		secondaryButton.isHidden = true
		
		// background color
		
		view.backgroundColor = viewModel.backgroundColor
		
		// update stack view spacing
		
		buttonsStackView.spacing = viewModel.spacer
		
		// update button constraints
		
		primaryButtonHeightConstraint.constant = viewModel.buttonHeight
		secondaryButtonHeightConstraint.constant = viewModel.buttonHeight
		
		// primary button
		primaryButton.customTextColor = viewModel.primaryTextColor
		primaryButton.enabledBackgroundColor = viewModel.primaryButtonColor
		primaryButton.hasBackground = !viewModel.primaryButtonInverted
		primaryButton.setTitle(viewModel.primaryButtonName, for: .normal)
		primaryButton.accessibilityIdentifier = viewModel.primaryIdentifier
		primaryButton.alpha = viewModel.isPrimaryButtonHidden ? 0.0 : 1.0
		primaryButton.isHidden = !viewModel.isPrimaryButtonEnabled
		primaryButton.isEnabled = viewModel.isPrimaryButtonEnabled
		
		// secondary button
		
		secondaryButton.customTextColor = viewModel.secondaryTextColor
		secondaryButton.enabledBackgroundColor = viewModel.secondaryButtonColor
		secondaryButton.hasBackground = !viewModel.secondaryButtonInverted
		secondaryButton.setTitle(viewModel.secondaryButtonName, for: .normal)
		secondaryButton.accessibilityIdentifier = viewModel.secondaryIdentifier
		secondaryButton.alpha = viewModel.isSecondaryButtonHidden ? 0.0 : 1.0
		secondaryButton.isHidden = !viewModel.isSecondaryButtonEnabled
		secondaryButton.isEnabled = viewModel.isSecondaryButtonEnabled

		// update loading indicators on model change

		viewModel.$isPrimaryLoading
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isLoading, on: primaryButton)
			.store(in: &subscription)

		viewModel.$isSecondaryLoading
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isLoading, on: secondaryButton)
			.store(in: &subscription)

		// update enabled state on model change

		viewModel.$isPrimaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isEnabled, on: primaryButton)
			.store(in: &subscription)

		viewModel.$isSecondaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.isEnabled, on: secondaryButton)
			.store(in: &subscription)

		// update hidden state on model change

		viewModel.$isPrimaryButtonHidden
			.receive(on: DispatchQueue.main.ocombine)
			.sink(receiveValue: { [weak self] isHidden in
				self?.primaryButton.isHidden = isHidden
				self?.animateHeightChange()
			})
			.store(in: &subscription)

		viewModel.$isSecondaryButtonHidden
			.receive(on: DispatchQueue.main.ocombine)
			.sink(receiveValue: { [weak self] isHidden in
				self?.secondaryButton.isHidden = isHidden
				self?.animateHeightChange()
			})
			.store(in: &subscription)

		viewModel.$backgroundColor
			.receive(on: DispatchQueue.main.ocombine)
			.assign(to: \.backgroundColor, on: view)
			.store(in: &subscription)

		viewModel.$topBottomInset
			.receive(on: DispatchQueue.main.ocombine)
			.sink(receiveValue: { [weak self] topBottomInset in
				self?.topInsetConstraint.constant = topBottomInset
				self?.bottomInsetConstraint.constant = -topBottomInset
			})
			.store(in: &subscription)
	}
	
	private func animateHeightChange() {
		let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut) { [weak self] in
			guard let self = self else {
				return
			}
			self.primaryButton.alpha = self.viewModel.isPrimaryButtonHidden ? 0.0 : 1.0
			self.secondaryButton.alpha = self.viewModel.isSecondaryButtonHidden ? 0.0 : 1.0
			self.buttonsStackView.layoutIfNeeded()
		}
		animator.startAnimation()
	}
}
