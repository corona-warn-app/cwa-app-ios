//
// 🦠 Corona-Warn-App
//

import UIKit

class TooltipViewController: UIViewController {
	
	// MARK: - Init
	
	init(
		viewModel: TooltipViewModel,
		onClose: @escaping CompletionVoid
	) {
		self.viewModel = viewModel
		self.onClose = onClose
		super.init(nibName: nil, bundle: nil)

		modalPresentationStyle = .popover
		popoverPresentationController?.delegate = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .enaColor(for: .textPrimary1).withAlphaComponent(0.9)

		setupLayout()
		setupContent()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		preferredContentSize = view.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
	}

	// MARK: - Private

	private let viewModel: TooltipViewModel
	
	private let containerStackView: UIStackView = {
		let stackview = UIStackView()
		stackview.distribution = .fillProportionally
		stackview.axis = .vertical
		stackview.alignment = .fill
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()

	private let headerStackView: UIStackView = {
		let stackview = UIStackView()
		stackview.distribution = .equalSpacing
		stackview.axis = .horizontal
		stackview.spacing = 16
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()

	private lazy var closeButton: UIButton = {
		let button = UIButton(type: .custom)
		let closeIcon = UIImage(imageLiteralResourceName: "Icons_Tooltip_Close")
		button.setImage(closeIcon, for: .normal)
		button.tintColor = .enaColor(for: .darkBackground)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		return button
	}()

	private let titleLabel: ENALabel = {
		let enaLabel = ENALabel()
		enaLabel.style = .headline
		enaLabel.textColor = .enaColor(for: .darkBackground)
		enaLabel.numberOfLines = 1
		enaLabel.translatesAutoresizingMaskIntoConstraints = false
		return enaLabel
	}()

	private let descriptionLabel: ENALabel = {
		let enaLabel = ENALabel()
		enaLabel.style = .body
		enaLabel.textColor = .enaColor(for: .darkBackground)
		enaLabel.numberOfLines = 0
		enaLabel.lineBreakMode = .byWordWrapping
		enaLabel.translatesAutoresizingMaskIntoConstraints = false
		return enaLabel
	}()
	
	private let onClose: CompletionVoid
	
	@objc
	private func closeButtonTapped() {
		onClose()
	}
	
	private func setupLayout() {
		view.addSubview(containerStackView)
		containerStackView.addArrangedSubview(headerStackView)
		headerStackView.addArrangedSubview(titleLabel)
		headerStackView.addArrangedSubview(closeButton)
		containerStackView.addArrangedSubview(descriptionLabel)
		
		view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
		
		containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
		containerStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
		containerStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
		
		closeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
	}
	
	private func setupContent() {
		titleLabel.text = viewModel.title
		descriptionLabel.text = viewModel.description
	}
}

// MARK: - Protocol UIPopoverPresentationControllerDelegate

extension TooltipViewController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return  .none
	}

	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		onClose()
	}
}
