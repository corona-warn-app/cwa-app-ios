//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestResultFamilyMemberViewModel {
	
	// MARK: - Init
	
	init(
		coronaTestType: CoronaTestType,
		coronaTestService: CoronaTestServiceProviding,
		onSubmissionConsentCellTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onContinueWithSymptomsFlowButtonTap: @escaping () -> Void,
		onContinueWarnOthersButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		onChangeToPositiveTestResult: @escaping () -> Void,
		onTestDeleted: @escaping () -> Void,
		onTestCertificateCellTap: @escaping(HealthCertificate, HealthCertifiedPerson) -> Void
	) {
		self.coronaTestType = coronaTestType
		self.coronaTestService = coronaTestService
		self.onSubmissionConsentCellTap = onSubmissionConsentCellTap
		self.onContinueWithSymptomsFlowButtonTap = onContinueWithSymptomsFlowButtonTap
		self.onContinueWarnOthersButtonTap = onContinueWarnOthersButtonTap
		self.onChangeToPositiveTestResult = onChangeToPositiveTestResult
		self.onTestDeleted = onTestDeleted
		self.onTestCertificateCellTap = onTestCertificateCellTap

		guard let coronaTest = coronaTestService.coronaTest(ofType: coronaTestType) else {
			onTestDeleted()
			return
		}

		self.coronaTest = coronaTest
		bindToCoronaTestUpdates()
	}
	
	// MARK: - Internal
	
	let onSubmissionConsentCellTap: (@escaping (Bool) -> Void) -> Void
	
	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	@OpenCombine.Published var shouldShowDeletionConfirmationAlert: Bool = false
	@OpenCombine.Published var error: CoronaTestServiceError?
	@OpenCombine.Published var shouldAttemptToDismiss: Bool = false
	@OpenCombine.Published var footerViewModel: FooterViewModel?
	
	var coronaTest: CoronaTest!
	
	var title: String {
		if showSpecialCaseForNegativeAntigenTest {
			return AppStrings.ExposureSubmissionResult.Antigen.title
		} else {
			return AppStrings.ExposureSubmissionResult.PCR.title
		}
	}
	
	func didTapPrimaryButton() {
		switch coronaTest.testResult {
		case .positive, .negative, .invalid, .expired:
			shouldShowDeletionConfirmationAlert = true
		case .pending:
			refreshTest()
		}
	}
	
	func didTapSecondaryButton() {
		switch coronaTest.testResult {
		case .pending:
			shouldShowDeletionConfirmationAlert = true
		case .positive, .negative, .invalid, .expired:
			break
		}
	}
	
	func deleteTest() {
		coronaTestService.moveTestToBin(coronaTestType)
		onTestDeleted()
	}
	
	func updateTestResultIfPossible() {
		guard coronaTest.testResult == .pending else {
			Log.info("Not refreshing test because status is pending")
			return
		}
		refreshTest()
	}
	
	// MARK: - Private
	
	private var coronaTestService: CoronaTestServiceProviding

	private let coronaTestType: CoronaTestType

	private let onContinueWithSymptomsFlowButtonTap: () -> Void
	private let onContinueWarnOthersButtonTap: (@escaping (Bool) -> Void) -> Void

	private let onChangeToPositiveTestResult: () -> Void
	private let onTestDeleted: () -> Void
	private let onTestCertificateCellTap: (HealthCertificate, HealthCertifiedPerson) -> Void

	private var subscriptions = Set<AnyCancellable>()
	
	private var primaryButtonIsLoading: Bool = false {
		didSet {
			footerViewModel?.setLoadingIndicator(primaryButtonIsLoading, disable: primaryButtonIsLoading, button: .primary)
			footerViewModel?.setLoadingIndicator(false, disable: primaryButtonIsLoading, button: .secondary)
		}
	}
	
	private var showSpecialCaseForNegativeAntigenTest: Bool {
		return coronaTest.type == .antigen && coronaTest.testResult == .negative
	}

	private func bindToCoronaTestUpdates() {
		switch coronaTestType {
		case .pcr:
			coronaTestService.pcrTest
				.sink { [weak self] pcrTest in
					guard let pcrTest = pcrTest else {
						return
					}

					self?.updateForCurrentTestResult(coronaTest: .pcr(pcrTest))
				}
				.store(in: &subscriptions)
		case .antigen:
			coronaTestService.antigenTest
				.sink { [weak self] antigenTest in
					guard let antigenTest = antigenTest else {
						return
					}

					self?.updateForCurrentTestResult(coronaTest: .antigen(antigenTest))
				}
				.store(in: &subscriptions)
		}
	}

	private func updateForCurrentTestResult(coronaTest: CoronaTest) {
		// Positive test results are not shown immediately
		if coronaTest.testResult == .positive && self.coronaTest.testResult != .positive {
			self.onChangeToPositiveTestResult()
		}

		self.coronaTest = coronaTest

		let sections: [DynamicSection]
		switch coronaTest.testResult {
		case .positive:
			sections = positiveTestResultSections
		case .negative:
			if let test = coronaTest.antigenTest, showSpecialCaseForNegativeAntigenTest {
				sections = negativeAntigenTestResultSections(test: test)
			} else {
				sections = negativeTestResultSections
			}
		case .invalid:
			sections = invalidTestResultSections
		case .pending:
			sections = pendingTestResultSections
		case .expired:
			sections = []
		}
		dynamicTableViewModel = DynamicTableViewModel(sections)
		
		footerViewModel = ExposureSubmissionTestResultViewModel.footerViewModel(coronaTest: coronaTest)
	}
	
	private func refreshTest() {
		Log.info("Refresh test.")

		primaryButtonIsLoading = true
		coronaTestService.updateTestResult(for: coronaTestType) { [weak self] result in
			guard let self = self else { return }
			
			self.primaryButtonIsLoading = false
			
			switch result {
			case let .failure(error):
				self.error = error
			case .success:
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
		
		switch coronaTest.type {
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
					description: AppStrings.ExposureSubmissionResult.PCR.familyMemberTestAdded,
					icon: UIImage(named: "Icons_Grey_Wait"),
					hairline: .iconAttached
				),
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.familyMemberTestCertificateTitle,
					description: AppStrings.ExposureSubmissionResult.familyMemberTestCertificatePending,
					icon: UIImage(named: "certificate-qr-light"),
					hairline: .none
				)
			])
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
				),
				ExposureSubmissionDynamicCell.stepCell(
					title: AppStrings.ExposureSubmissionResult.familyMemberAntigenTestCertificateTitle,
					description: AppStrings.ExposureSubmissionResult.familyMemberAntigenTestCertificatePending,
					icon: UIImage(named: "certificate-qr-light"),
					hairline: .none
				)
			])
		}
		
		return [
			.section(
				header: .identifier(
					ExposureSubmissionTestResultViewController.HeaderReuseIdentifier.pcrTestResult,
					configure: { view, _ in
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
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

		if coronaTest.type == .pcr {
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
		} else if coronaTest.type == .antigen {
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
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
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

		if let test = coronaTest.antigenTest, showSpecialCaseForNegativeAntigenTest {
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
					(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
				}
			)
		}
		
		var cells = [DynamicCell]()

		// Health Certificate
		if coronaTest.certificateRequested, let healthTuple = coronaTestService.healthCertificateTuple(for: coronaTest.uniqueCertificateIdentifier ?? "") {
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

		#if DEBUG

		if isUITesting && LaunchArguments.healthCertificate.showTestCertificateOnTestResult.boolValue, let healthTuple = coronaTestService.mockHealthCertificateTuple() {
			cells.append(mockTestCertificateCell(certificate: healthTuple.certificate, certifiedPerson: healthTuple.certifiedPerson))
		}
		
		#endif

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
		
		switch coronaTest.type {
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
	
	private func negativeAntigenTestResultSections(test: AntigenTest) -> [DynamicSection] {
		var cells = [DynamicCell]()

		// Health Certificate
		if test.certificateRequested, let healthTuple = coronaTestService.healthCertificateTuple(for: test.uniqueCertificateIdentifier ?? "") {
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

		#if DEBUG

		if isUITesting && LaunchArguments.healthCertificate.showTestCertificateOnTestResult.boolValue, let healthTuple = coronaTestService.mockHealthCertificateTuple() {
			cells.append(mockTestCertificateCell(certificate: healthTuple.certificate, certifiedPerson: healthTuple.certifiedPerson))
		}
		
		#endif

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
	
	#if DEBUG

	private func mockTestCertificateCell(certificate: HealthCertificate, certifiedPerson: HealthCertifiedPerson) -> DynamicCell {
		return DynamicCell.identifier(
			ExposureSubmissionTestResultViewController.CustomCellReuseIdentifiers.healthCertificateCell,
			action: .execute { _, _ in
				self.onTestCertificateCellTap(certificate, certifiedPerson)
			},
			configure: { _, cell, _ in
				guard let cell = cell as? HealthCertificateCell else {
					fatalError("could not initialize cell of type `HealthCertificateCell`")
				}
				cell.configure(
					HealthCertificateCellViewModel(
						healthCertificate: certificate,
						healthCertifiedPerson: certifiedPerson
					)
				)
			})
	}
	
	#endif
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

		switch coronaTest.type {
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
						(view as? ExposureSubmissionTestResultHeaderView)?.configure(coronaTest: self.coronaTest)
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
	
	static func footerViewModel(coronaTest: CoronaTest) -> FooterViewModel {
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
