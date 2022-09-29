//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class AppInformationViewController: DynamicTableViewController, NavigationBarOpacityDelegate {
	
	// MARK: - Init
	
	init(
		elsService: ErrorLogSubmissionProviding,
		cclService: CCLServable
	) {
		self.cclService = cclService

		self.model = [
			.versionInfo: AppInformationCellModel(
				text: AppStrings.AppInformation.newFeaturesNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.newFeaturesNavigation,
				action: .push(viewController: DeltaOnboardingNewVersionFeaturesViewController(hasCloseButton: false))
			),
			.about: AppInformationCellModel(
				text: AppStrings.AppInformation.aboutNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutNavigation,
				action: .push(model: AppInformationModel.aboutModel, withTitle: AppStrings.AppInformation.aboutNavigation)
			),
			.terms: AppInformationCellModel(
				text: AppStrings.AppInformation.termsTitle,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.termsNavigation,
				action: .push(htmlModel: AppInformationModel.termsModel, withTitle: AppStrings.AppInformation.termsNavigation)
			),
			.accessibility: AppInformationCellModel(
				text: AppStrings.AppInformation.accessibilityNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.accessibilityNavigation,
				action: .safariAccessibility
			),
			.privacy: AppInformationCellModel(
				text: AppStrings.AppInformation.privacyNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.privacyNavigation,
				action: .push(htmlModel: AppInformationModel.privacyModel, withTitle: AppStrings.AppInformation.privacyNavigation)
			),
			.legal: AppInformationCellModel(
				text: AppStrings.AppInformation.legalNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.legalNavigation,
				action: .push(model: AppInformationViewController.legalModel, separators: true, withTitle: AppStrings.AppInformation.legalNavigation)
			),
			.contact: AppInformationCellModel(
				text: AppStrings.AppInformation.contactNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactNavigation,
				action: .push(model: AppInformationModel.contactModel, withTitle: AppStrings.AppInformation.contactNavigation)
			),
			.errorReport: AppInformationCellModel(
				text: AppStrings.ErrorReport.title,
				accessibilityIdentifier: AccessibilityIdentifiers.ErrorReport.navigation,
				action: .pushErrorLogsCoordinator(
					elsService: elsService
				)
			),
			.imprint: AppInformationCellModel(
				text: AppStrings.AppInformation.imprintNavigation,
				accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
				action: .push(model: imprintViewModel.dynamicTable, withTitle: AppStrings.AppInformation.imprintNavigation)
			)
		]
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.backgroundColor = .enaColor(for: .separator)
		tableView.separatorColor = .enaColor(for: .hairline)

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.AppInformation.appInformationNavigationTitle

		dynamicTableViewModel = .init([
			.section(
				header: .space(height: 32),
				footer: .view(footerView()),
				separators: .none,
				cells: Category.allCases.compactMap { model[$0] }.map { .body(text: $0.text, accessibilityIdentifier: $0.accessibilityIdentifier) }
			)
		])
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// navigationbar is a shared property - so we need to trigger a resizing because others could have set it to false
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()
	}
	
	// MARK: - Protocol UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.selectionStyle = .default
		cell.isAccessibilityElement = true
		cell.accessibilityLabel = cell.textLabel?.text
		if let category = Category(rawValue: indexPath.row),
			let accessibilityIdentifier = model[category]?.accessibilityIdentifier {
			cell.accessibilityIdentifier = accessibilityIdentifier
			switch category {
			case .accessibility:
				let imageView = UIImageView(image: UIImage(named: "icons_safari_link"))
				imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
				imageView.contentMode = .scaleAspectFill
				cell.accessoryView = imageView
			case .about, .contact, .errorReport, .imprint, .legal, .privacy, .versionInfo, .terms:
				cell.accessoryType = .disclosureIndicator
			}
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if let category = Category(rawValue: indexPath.row) {
			
			if category == .versionInfo {
				execute(action: versionInfoAppInformationCellModel.action)
			} else {
				if let action = model[category]?.action {
					execute(action: action)
				}
			}
		}
	}
	
	// MARK: - Public
	
	// MARK: - Internal
	
	enum Category: Int, Hashable, CaseIterable {
		case versionInfo
		case about
		case terms
		case accessibility
		case privacy
		case legal
		case contact
		case errorReport
		case imprint
	}
	
	var preferredLargeTitleBackgroundColor: UIColor? { .enaColor(for: .background) }
	
	let imprintViewModel = AppInformationImprintViewModel(preferredLocalization: Bundle.main.preferredLocalizations.first ?? "de")

	var model: [Category: AppInformationCellModel]
	
	// MARK: - Private

	private var cclService: CCLServable
	
	private func footerView() -> UIView {
		let versionLabel = ENALabel()
		versionLabel.translatesAutoresizingMaskIntoConstraints = false
		versionLabel.numberOfLines = 0
		versionLabel.textColor = .enaColor(for: .textPrimary2)
		versionLabel.style = .footnote
		versionLabel.textAlignment = .center

		let bundleVersion = Bundle.main.appVersion
		let bundleBuild = Bundle.main.appBuildNumber
		versionLabel.text = [
			String(format: AppStrings.AppInformation.appInformationAppVersion, "\(bundleVersion) (\(bundleBuild))"),
			String(format: AppStrings.AppInformation.appInformationCCLVersion, "\(cclService.configurationVersion)")
		].joined(separator: "\n")

		let footerView = UIView()
		footerView.addSubview(versionLabel)

		versionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
		versionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16).isActive = true
		versionLabel.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -16).isActive = true

		return footerView
	}
	
	private var versionInfoAppInformationCellModel: AppInformationCellModel {
		AppInformationCellModel(
			text: AppStrings.AppInformation.newFeaturesNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.newFeaturesNavigation,
			action: .push(viewController: DeltaOnboardingNewVersionFeaturesViewController(hasCloseButton: false))
		)
	}
}
