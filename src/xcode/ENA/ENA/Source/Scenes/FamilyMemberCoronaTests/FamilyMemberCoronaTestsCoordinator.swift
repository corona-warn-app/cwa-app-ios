//
// 🦠 Corona-Warn-App
//

import UIKit
import PDFKit

class FamilyMemberCoronaTestsCoordinator {
	
	// MARK: - Init
	
	init(
		parentNavigationController: UINavigationController,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		appConfigurationProvider: AppConfigurationProviding,
		store: HealthCertificateStoring,
		healthCertificateService: HealthCertificateService,
		healthCertificateValidationService: HealthCertificateValidationProviding,
		vaccinationValueSetsProvider: VaccinationValueSetsProviding,
		healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding
	) {
		self.parentNavigationController = parentNavigationController
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.appConfigurationProvider = appConfigurationProvider
		self.store = store
		self.healthCertificateService = healthCertificateService
		self.healthCertificateValidationService = healthCertificateValidationService
		self.vaccinationValueSetsProvider = vaccinationValueSetsProvider
		self.healthCertificateValidationOnboardedCountriesProvider = healthCertificateValidationOnboardedCountriesProvider
	}

	// MARK: - Internal

	func start() {
		parentNavigationController.pushViewController(coronaTestsScreen, animated: true)
	}
	
	// MARK: - Private
	
	private let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	private let appConfigurationProvider: AppConfigurationProviding
	private let store: HealthCertificateStoring
	private let healthCertificateService: HealthCertificateService
	private let healthCertificateValidationService: HealthCertificateValidationProviding
	private let vaccinationValueSetsProvider: VaccinationValueSetsProviding
	private let healthCertificateValidationOnboardedCountriesProvider: HealthCertificateValidationOnboardedCountriesProviding

	private weak var parentNavigationController: UINavigationController!
	private var testResultNavigationController: UINavigationController!
	private var certificateCoordinator: HealthCertificateCoordinator?

	// MARK: Show Screens
	
	private lazy var coronaTestsScreen: UIViewController = {
		let coronaTestsViewController = FamilyMemberCoronaTestsViewController(
			viewModel: FamilyMemberCoronaTestsViewModel(
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				appConfigurationProvider: appConfigurationProvider,
				onCoronaTestCellTap: { [weak self] coronaTest in
					self?.showTestResultScreen(coronaTest: coronaTest)
				},
				onLastDeletion: { [weak self] in
					self?.parentNavigationController.popToRootViewController(animated: true)
				}
			)
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.FamilyMemberCoronaTest.deleteAllButtonTitle,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: true,
				isSecondaryButtonHidden: true,
				primaryButtonColor: .systemRed
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: coronaTestsViewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}()

	private func showTestResultScreen(coronaTest: FamilyMemberCoronaTest) {
		let testResultViewController = ExposureSubmissionTestResultViewController(
			viewModel: ExposureSubmissionTestResultFamilyMemberViewModel(
				familyMemberCoronaTest: coronaTest,
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				keepMarkedAsNew: false,
				onTestDeleted: { [weak self] in
					self?.testResultNavigationController.dismiss(animated: true)
				},
				onTestCertificateCellTap: { [weak self] healthCertificate, healthCertifiedPerson in
					self?.showHealthCertificateFlow(
						healthCertifiedPerson: healthCertifiedPerson,
						healthCertificate: healthCertificate
					)
				}
			),
			onDismiss: { [weak self] _, _ in
				self?.testResultNavigationController.dismiss(animated: true)
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Details.printVersionButtonTitle,
				secondaryButtonName: AppStrings.TraceLocations.Details.duplicateButtonTitle,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: false,
				secondaryButtonInverted: true,
				backgroundColor: .enaColor(for: .cellBackground)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: testResultViewController,
			bottomController: footerViewController
		)

		testResultNavigationController = UINavigationController(rootViewController: topBottomContainerViewController)
		parentNavigationController?.present(testResultNavigationController, animated: true)
	}

	private func showHealthCertificateFlow(
		healthCertifiedPerson: HealthCertifiedPerson,
		healthCertificate: HealthCertificate
	) {
		certificateCoordinator = HealthCertificateCoordinator(
			parentingViewController: .push(testResultNavigationController),
			healthCertifiedPerson: healthCertifiedPerson,
			healthCertificate: healthCertificate,
			store: store,
			healthCertificateService: healthCertificateService,
			healthCertificateValidationService: healthCertificateValidationService,
			healthCertificateValidationOnboardedCountriesProvider: healthCertificateValidationOnboardedCountriesProvider,
			vaccinationValueSetsProvider: vaccinationValueSetsProvider,
			markAsSeenOnDisappearance: true
		)

		certificateCoordinator?.start()
	}
	
}
