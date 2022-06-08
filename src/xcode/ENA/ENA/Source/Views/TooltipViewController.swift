//
// 🦠 Corona-Warn-App
//

import UIKit

class TooltipViewController: UIViewController, UIPopoverPresentationControllerDelegate {

	let containerStackView: UIStackView = {
		let stackview = UIStackView()
		stackview.distribution = .fillProportionally
		stackview.axis = .vertical
		stackview.alignment = .fill
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()

	let headerStackView: UIStackView = {
		let stackview = UIStackView()
		stackview.distribution = .equalSpacing
		stackview.axis = .horizontal
		stackview.spacing = 16
		stackview.translatesAutoresizingMaskIntoConstraints = false
		return stackview
	}()

	lazy var closeButton: UIButton = {
		let button = UIButton(type: .custom)
		let closeIcon = UIImage(imageLiteralResourceName: "Icons_Tooltip_Close")
		button.setImage(closeIcon, for: .normal)
		button.tintColor = .enaColor(for: .darkBackground)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		return button
	}()

	let titleLabel: ENALabel = {
		let enaLabel = ENALabel()
		enaLabel.style = .headline
		enaLabel.textColor = .enaColor(for: .darkBackground)
		enaLabel.numberOfLines = 1
		enaLabel.translatesAutoresizingMaskIntoConstraints = false
		return enaLabel
	}()

	let descriptionLabel: ENALabel = {
		let enaLabel = ENALabel()
		enaLabel.style = .body
		enaLabel.textColor = .enaColor(for: .darkBackground)
		enaLabel.numberOfLines = 0
		enaLabel.lineBreakMode = .byWordWrapping
		enaLabel.translatesAutoresizingMaskIntoConstraints = false
		return enaLabel
	}()

	let viewModel: TooltipViewModel

	init(viewModel: TooltipViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)

		modalPresentationStyle = .popover
		popoverPresentationController?.delegate = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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

	// MARK: - Protocol UIPopoverPresentationControllerDelegate

	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return  .none
	}

	func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
		viewModel.onClose()
	}

	// MARK: - Private

	@objc
	private func closeButtonTapped() {
		viewModel.onClose()
	}
	
	private func setupLayout() {
		view.addSubview(containerStackView)
		containerStackView.addArrangedSubview(headerStackView)
		headerStackView.addArrangedSubview(titleLabel)
		headerStackView.addArrangedSubview(closeButton)
		containerStackView.addArrangedSubview(descriptionLabel)
		
		view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8).isActive = true
		
		containerStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
		containerStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4).isActive = true
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
