//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestResultFamilyMemberViewModel: ExposureSubmissionTestResultModeling {
	
	// MARK: - Init
	
	init(
		familyMemberCoronaTest: FamilyMemberCoronaTest,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		onTestDeleted: @escaping () -> Void,
		onTestCertificateCellTap: @escaping(HealthCertificate, HealthCertifiedPerson) -> Void
	) {
		self.familyMemberCoronaTest = familyMemberCoronaTest
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.onTestDeleted = onTestDeleted
		self.onTestCertificateCellTap = onTestCertificateCellTap

		guard let familyMemberCoronaTest = familyMemberCoronaTestService.upToDateTest(for: familyMemberCoronaTest) else {
			onTestDeleted()
			return
		}

		self.familyMemberCoronaTest = familyMemberCoronaTest

		bindToCoronaTestUpdates()
	}
	
	// MARK: - Internal
	
	var dynamicTableViewModelPublisher = CurrentValueSubject<DynamicTableViewModel, Never>(DynamicTableViewModel([]))
	var shouldShowDeletionConfirmationAlertPublisher = CurrentValueSubject<Bool, Never>(false)
	var errorPublisher = CurrentValueSubject<CoronaTestServiceError?, Never>(nil)
	var shouldAttemptToDismissPublisher = CurrentValueSubject<Bool, Never>(false)
	var footerViewModelPublisher = CurrentValueSubject<FooterViewModel?, Never>(nil)

	var title: String {
		return familyMemberCoronaTest.displayName
	}
	
	var testResult: TestResult {
		return familyMemberCoronaTest.testResult
	}
	
	func didTapPrimaryButton() {
		switch familyMemberCoronaTest.testResult {
		case .positive, .negative, .invalid, .expired:
			shouldShowDeletionConfirmationAlertPublisher.value = true
		case .pending:
			refreshTest()
		}
	}
	
	func didTapSecondaryButton() {
		switch familyMemberCoronaTest.testResult {
		case .pending:
			shouldShowDeletionConfirmationAlertPublisher.value = true
		case .positive, .negative, .invalid, .expired:
			break
		}
	}
	
	func deleteTest() {
		familyMemberCoronaTestService.moveTestToBin(familyMemberCoronaTest)
		onTestDeleted()
	}
	
	func evaluateShowing() {
		familyMemberCoronaTestService.evaluateShowing(of: familyMemberCoronaTest)
	}
	
	func updateTestResultIfPossible() {
		guard familyMemberCoronaTest.testResult == .pending else {
			Log.info("Not refreshing test because status is not pending")
			return
		}
		refreshTest()
	}
	
	// MARK: - Private
	
	private var familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	private var familyMemberCoronaTest: FamilyMemberCoronaTest

	private let onTestDeleted: () -> Void
	private let onTestCertificateCellTap: (HealthCertificate, HealthCertifiedPerson) -> Void

	private var subscriptions = Set<AnyCancellable>()
	
	private var primaryButtonIsLoading: Bool = false {
		didSet {
			footerViewModelPublisher.value?.setLoadingIndicator(primaryButtonIsLoading, disable: primaryButtonIsLoading, button: .primary)
			footerViewModelPublisher.value?.setLoadingIndicator(false, disable: primaryButtonIsLoading, button: .secondary)
		}
	}
	
	private var showSpecialCaseForNegativeAntigenTest: Bool {
		return familyMemberCoronaTest.type == .antigen && familyMemberCoronaTest.testResult == .negative
	}

	private func bindToCoronaTestUpdates() {
		familyMemberCoronaTestService.coronaTests
			.sink { [weak self] _ in
				
				guard let familyMemberCoronaTest = self?.familyMemberCoronaTest, let familyMemberCoronaTest = self?.familyMemberCoronaTestService.upToDateTest(for: familyMemberCoronaTest) else {
					return
				}

				self?.updateSectionsForCurrentTestResult(coronaTest: familyMemberCoronaTest)
			}
			.store(in: &subscriptions)
	}

	private func updateSectionsForCurrentTestResult(coronaTest: FamilyMemberCoronaTest) {
		self.familyMemberCoronaTest = coronaTest

		primaryButtonIsLoading = coronaTest.isLoading
		
		let sections: [DynamicSection]
		switch coronaTest.testResult {
		case .positive:
			sections = positiveTestResultSections
		case .negative:
			if let test = familyMemberCoronaTest.antigenTest, showSpecialCaseForNegativeAntigenTest {
				sections = negativeAntigenTestResultSections(test: test)
			} else {
				sections = negativeTestResultSections
			}
		case .invalid:
			sections = invalidTestResultSections
		case .pending:
			sections = pendingTestResultSections
		case .expired:
			onTestDeleted()
			return
		}
		dynamicTableViewModelPublisher.value = DynamicTableViewModel(sections)
		
		footerViewModelPublisher.value = ExposureSubmissionTestResultFamilyMemberViewModel.footerViewModel(coronaTest: coronaTest)
	}
	
	private func refreshTest() {
		Log.info("Refresh test.")

		familyMemberCoronaTestService.updateTestResult(for: familyMemberCoronaTest, presentNotification: false) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case let .failure(error):
				self.errorPublisher.value = error
			case .success:
				// we don't need to handle anything here as the subscriber in bindToCoronaTestUpdates() take care of the updates
				break
			}
		}
	}
}

// MARK: - Pending

extension ExposureSubmissionTestResultFamilyMemberViewModel {
	
	private var pendingTestResultSections: [DynamicSection] {
		var cells = [DynamicCell.title2(
						text: AppStrings.ExposureSubmissionResult.procedure,
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
		)]
		
		switch familyMemberCoronaTest.type {
		case .pcr:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.familyMemberTestAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				),
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.familyMemberTestPending,
					description: AppStrings.ExposureSubmissionResult.PCR.familyMemberTestPendingDesc,
					icon: UIImage(named: "Icons_Grey_Wait"),
					hairline: .iconAttached
				)
			])
			if !familyMemberCoronaTest.certificateSupportedByPointOfCare {
				cells.append(
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
						description: AppStrings.ExposureSubmissionResult.testCenterNotSupportedTitle,
						icon: UIImage(named: "certificate-qr-light"),
						hairline: .none
					)
				)
			} else if !familyMemberCoronaTest.certificateConsentGiven {
				cells.append(
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
						description: AppStrings.ExposureSubmissionResult.testCertificateNotRequested,
						icon: UIImage(named: "certificate-qr-light"),
						hairline: .none
					)
				)
			} else {
				cells.append(
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
						description: AppStrings.ExposureSubmissionResult.testCertificatePending,
						icon: UIImage(named: "certificate-qr-light"),
						hairline: .none
					)
				)
			}
			
		case .antigen:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.Antigen.familyMemberTestAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				),
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.Antigen.familyMemberTestPending,
					description: AppStrings.ExposureSubmissionResult.Antigen.familyMemberTestPendingDesc,
					icon: UIImage(named: "Icons_Grey_Wait"),
					hairline: .iconAttached
				)
			])
			if !familyMemberCoronaTest.certificateSupportedByPointOfCare {
				cells.append(
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
						description: AppStrings.ExposureSubmissionResult.testCenterNotSupportedTitle,
						icon: UIImage(named: "certificate-qr-light"),
						hairline: .none
					)
				)
			} else if !familyMemberCoronaTest.certificateConsentGiven {
				cells.append(
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
						description: AppStrings.ExposureSubmissionResult.testCertificateNotRequested,
						icon: UIImage(named: "certificate-qr-light"),
						hairline: .none
					)
				)
			} else {
				cells.append(
					ExposureSubmissionDynamicCell.stepCell(
						title: AppStrings.ExposureSubmissionResult.testCertificateTitle,
						description: AppStrings.ExposureSubmissionResult.testCertificatePending,
						icon: UIImage(named: "certificate-qr-light"),
						hairline: .none
					)
				)
			}
		}
		
		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.familyMemberCoronaTest)
					}
				),
				cells: cells
			)
		]
	}
}

// MARK: - Positive

extension ExposureSubmissionTestResultFamilyMemberViewModel {

	private var positiveTestResultSections: [DynamicSection] {
		var cells: [DynamicCell] = [
			.title2(text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedTitle1)
		]

		if familyMemberCoronaTest.type == .pcr {
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedPCRInfo1,
					icon: UIImage(named: "Icons - Home"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedPCRInfo2,
					icon: UIImage(named: "Icons - Hotline"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedPCRInfo3,
					icon: UIImage(named: "Icons - Red Plus"),
					hairline: .none,
					bottomSpacing: .medium
				)
			])
		} else if familyMemberCoronaTest.type == .antigen {
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedRATInfo1,
					icon: UIImage(named: "Icons - Home"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedRATInfo2,
					icon: UIImage(named: "Icons - Test Tube"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				),
				ExposureSubmissionDynamicCell.stepCell(
					style: .body,
					title: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedRATInfo3,
					icon: UIImage(named: "Icons - Hotline"),
					iconTint: .enaColor(for: .riskHigh),
					hairline: .none,
					bottomSpacing: .medium
				)
			])
		}

		cells.append(contentsOf: [
			.title2(text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedTitle2),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo1,
				spacing: .large
			),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo2,
				spacing: .large
			),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo3,
				spacing: .large
			),
			.bulletPoint(
				text: AppStrings.ExposureSubmissionPositiveTestResult.keysSubmittedFurtherInfo4,
				spacing: .large
			)
		])

		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.familyMemberCoronaTest)
					}
				),
				separators: .none,
				cells: cells
			)
		]
	}
}

// MARK: - Negative

extension ExposureSubmissionTestResultFamilyMemberViewModel {
	
	private var negativeTestResultSections: [DynamicSection] {
		
		let header: DynamicHeader

		if let test = familyMemberCoronaTest.antigenTest, showSpecialCaseForNegativeAntigenTest {
			header = .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.antigenTestResult,
				configure: { view, _ in
					(view as? AntigenExposureSubmissionNegativeTestResultHeaderView)?.configure(coronaTest: test)
				}
			)
		} else {
			header = .identifier(
				ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
				configure: { view, _ in
					(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.familyMemberCoronaTest)
				}
			)
		}
		
		var cells = [DynamicCell]()

		// Health Certificate
		if familyMemberCoronaTest.certificateRequested, let healthTuple = familyMemberCoronaTestService.healthCertificateTuple(for: familyMemberCoronaTest.uniqueCertificateIdentifier ?? "") {
			cells.append(DynamicCell.identifier(
				ExposureSubmissionTestResultViewController.CustomCellReuseIdentifiers.healthCertificateCell,
				action: .execute { _, _ in
					self.onTestCertificateCellTap(healthTuple.certificate, healthTuple.certifiedPerson)
				},
				configure: { _, cell, _ in
					guard let cell = cell as? HealthCertificateCell else {
						fatalError("could not initialize cell of type `HealthCertificateCell`")
					}
					
					cell.configure(
						HealthCertificateCellViewModel(
							healthCertificate: healthTuple.certificate,
							healthCertifiedPerson: healthTuple.certifiedPerson
						)
					)
				})
			)
		}

		// Evidence / Proof
		cells.append(contentsOf: [
			.body(
				text: AppStrings.ExposureSubmissionResult.Antigen.proofDesc,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.Antigen.proofDesc
			)
		])
		
		// Information on proceduce
		cells.append(DynamicCell.title2(
			text: AppStrings.ExposureSubmissionResult.procedure,
			accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
		))
		
		switch familyMemberCoronaTest.type {
		case .pcr:
			cells.append(
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.familyMemberTestAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			)
			
		case .antigen:
			cells.append(
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.Antigen.familyMemberTestAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			)
		}
		
		cells.append(contentsOf: [
			ExposureSubmissionDynamicCell.stepCell(
				title: AppStrings.ExposureSubmissionResult.testNegative,
				description: AppStrings.ExposureSubmissionResult.testNegativeDesc,
				icon: UIImage(named: "Icons_Grey_Error"),
				hairline: .topAttached
			)
		])

		// Further Information
		cells.append(contentsOf: [
			.title2(
				text: AppStrings.ExposureSubmissionResult.furtherInfos_Title,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.furtherInfos_Title
			),
			.body(text: AppStrings.ExposureSubmissionResult.furtherInfos_Desc),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem1, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem2, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem3, spacing: .large)
		])
		
		return [
			.section(
				header: header,
				separators: .none,
				cells: cells
			)
		]
	}
	
	private func negativeAntigenTestResultSections(test: FamilyMemberAntigenTest) -> [DynamicSection] {
		var cells = [DynamicCell]()

		// Health Certificate
		if test.certificateRequested, let healthTuple = familyMemberCoronaTestService.healthCertificateTuple(for: test.uniqueCertificateIdentifier ?? "") {
			cells.append(DynamicCell.identifier(
				ExposureSubmissionTestResultViewController.CustomCellReuseIdentifiers.healthCertificateCell,
				action: .execute { _, _ in
					self.onTestCertificateCellTap(healthTuple.certificate, healthTuple.certifiedPerson)
				},
				configure: { _, cell, _ in
					guard let cell = cell as? HealthCertificateCell else {
						fatalError("could not initialize cell of type `HealthCertificateCell`")
					}
					
					cell.configure(
						HealthCertificateCellViewModel(
							healthCertificate: healthTuple.certificate,
							healthCertifiedPerson: healthTuple.certifiedPerson
						)
					)
				})
			)
		}

		// Evidence / Proof
		cells.append(contentsOf: [
			.body(
				text: AppStrings.ExposureSubmissionResult.Antigen.proofDesc,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.Antigen.proofDesc
			)
		])
		
		// Information on proceduce
		cells.append(contentsOf: [
			.title2(
				text: AppStrings.ExposureSubmissionResult.procedure,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
			),
			ExposureSubmissionDynamicCell.stepCell(
				title: AppStrings.ExposureSubmissionResult.Antigen.familyMemberTestAdded,
				description: nil,
				icon: UIImage(named: "Icons_Grey_Check"),
				hairline: .iconAttached
			),
			ExposureSubmissionDynamicCell.stepCell(
				title: AppStrings.ExposureSubmissionResult.testNegative,
				description: AppStrings.ExposureSubmissionResult.Antigen.testNegativeDesc,
				icon: UIImage(named: "Icons_Grey_Error"),
				hairline: .topAttached
			)
		])

		// Further Information
		cells.append(contentsOf: [
			.title2(
				text: AppStrings.ExposureSubmissionResult.furtherInfos_Title,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.furtherInfos_Title
			),
			.body(text: AppStrings.ExposureSubmissionResult.furtherInfos_Desc),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem1, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem2, spacing: .large),
			.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem3, spacing: .large)
		])

		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.antigenTestResult,
					configure: { view, _ in
						(view as? AntigenExposureSubmissionNegativeTestResultHeaderView)?.configure(coronaTest: test)
					}
				),
				separators: .none,
				cells: cells
			)
		]
	}
}

// MARK: - Invalid

extension ExposureSubmissionTestResultFamilyMemberViewModel {
	
	private var invalidTestResultSections: [DynamicSection] {
		var cells = [
			DynamicCell.title2(
				text: AppStrings.ExposureSubmissionResult.procedure,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureSubmissionResult.procedure
			)
		]

		switch familyMemberCoronaTest.type {
		case .pcr:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.PCR.familyMemberTestAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			])
		case .antigen:
			cells.append(contentsOf: [
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.Antigen.familyMemberTestAdded,
					description: nil,
					icon: UIImage(named: "Icons_Grey_Check"),
					hairline: .iconAttached
				)
			])
		}

		cells.append(contentsOf: [
			ExposureSubmissionDynamicCell.stepCell(
				title: AppStrings.ExposureSubmissionResult.testInvalid,
				description: AppStrings.ExposureSubmissionResult.testInvalidDesc,
				icon: UIImage(named: "Icons_Grey_Error"),
				hairline: .topAttached
			)
		])

		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.familyMemberCoronaTest)
					}
				),
				separators: .none,
				cells: cells
			)
		]
	}
}

// MARK: - Footer view helper

extension ExposureSubmissionTestResultFamilyMemberViewModel {
	
	static func footerViewModel(coronaTest: FamilyMemberCoronaTest) -> FooterViewModel {
		switch coronaTest.testResult {
		case .positive, .negative, .invalid, .expired:
			return FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionResult.deleteButton,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		case .pending:
			return FooterViewModel(
				primaryButtonName: AppStrings.ExposureSubmissionResult.refreshButton,
				secondaryButtonName: AppStrings.ExposureSubmissionResult.deleteButton,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				secondaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.secondaryButton,
				secondaryButtonInverted: true
			)
		}
	}
	
	// swiftlint:disable:next file_length
}
