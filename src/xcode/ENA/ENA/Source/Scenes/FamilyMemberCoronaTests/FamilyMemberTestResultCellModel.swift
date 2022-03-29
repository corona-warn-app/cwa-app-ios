//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class FamilyMemberTestResultCellModel {

	// MARK: - Init

	init(
		coronaTest: FamilyMemberCoronaTest,
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		onUpdate: @escaping () -> Void
	) {
		self.coronaTest = coronaTest
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.onUpdate = onUpdate

		setup()
	}

	// MARK: - Internal

	@OpenCombine.Published var name: String! = ""
	@OpenCombine.Published var caption: String! = ""
	@OpenCombine.Published var topDiagnosis: String! = ""
	@OpenCombine.Published var bottomDiagnosis: String?
	@OpenCombine.Published var bottomDiagnosisColor: UIColor! = .enaColor(for: .riskLow)
	@OpenCombine.Published var description: String?
	@OpenCombine.Published var footnote: String?
	@OpenCombine.Published var buttonTitle: String?
	@OpenCombine.Published var image: UIImage?
	@OpenCombine.Published var isUnreadNewsIndicatorHidden: Bool = true
	@OpenCombine.Published var isDisclosureIndicatorHidden: Bool = false
	@OpenCombine.Published var isUserInteractionEnabled: Bool = false
	@OpenCombine.Published var isCellTappable: Bool = true
	@OpenCombine.Published var accessibilityIdentifier: String! = AccessibilityIdentifiers.Home.TestResultCell.unconfiguredButton

	// MARK: - Private

	private var coronaTest: FamilyMemberCoronaTest
	private let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	private let onUpdate: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	// swiftlint:disable:next cyclomatic_complexity
	private func setup() {
		switch coronaTest.type {
		case .pcr:
			title = AppStrings.Home.TestResult.pcrTitle
		case .antigen:
			title = AppStrings.Home.TestResult.antigenTitle
		}

		familyMemberCoronaTestService.coronaTests
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self, let updatedCoronaTest = self.familyMemberCoronaTestService.upToDateTest(for: self.coronaTest) else {
					return
				}

				if updatedCoronaTest != self.coronaTest {
					self.coronaTest = updatedCoronaTest
					self.configure()
					self.onUpdate()
				}
			}
			.store(in: &subscriptions)
	}

	private func configure() {
		name = coronaTest.displayName

		guard !coronaTest.isOutdated else {
			configureTestResultOutdated()
			return
		}

		switch coronaTest.testResult {
		case .invalid: configureTestResultInvalid()
		case .pending: configureTestResultPending()
		case .negative: configureTestResultNegative()
		case .positive: configureTestResultPositive()
		case .expired: configureTestResultExpired()
		}
	}

	private func configureTestResultNegative() {
		description = AppStrings.Home.TestResult.Negative.description

		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none

		let dateTemplate: String
		switch coronaTest.type {
		case .pcr:
			dateTemplate = AppStrings.Home.TestResult.Negative.datePCR
		case .antigen:
			dateTemplate = AppStrings.Home.TestResult.Negative.dateAntigen
		}

		let formattedTestDate = dateFormatter.string(from: coronaTest.testDate)
		footnote = String(format: dateTemplate, formattedTestDate)

		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "FamilyMember_CoronaTest_negative")
		isDisclosureIndicatorHidden = false
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.negativePCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.negativeAntigenButton
		}
	}

	private func configureTestResultInvalid() {
		description = AppStrings.Home.TestResult.Invalid.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "FamilyMember_CoronaTest_invalid_expired")
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.invalidPCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.invalidAntigenButton
		}
	}

	private func configureTestResultPending() {
		switch coronaTest.type {
		case .pcr:
			description = AppStrings.Home.TestResult.Pending.pcrDescription
		case .antigen:
			description = AppStrings.Home.TestResult.Pending.antigenDescription
		}

		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.showResult
		image = UIImage(named: "FamilyMember_CoronaTest_pending")
		isDisclosureIndicatorHidden = false
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.pendingPCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.pendingAntigenButton
		}
	}

	private func configureTestResultPositive() {
		description = AppStrings.Home.TestResult.Available.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.retrieveResult
		image = UIImage(named: "FamilyMember_CoronaTest_positive")
		isDisclosureIndicatorHidden = false
		isUserInteractionEnabled = true
		isCellTappable = true

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.availablePCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.availableAntigenButton
		}
	}

	private func configureTestResultExpired() {
		description = AppStrings.Home.TestResult.Expired.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.deleteTest
		image = UIImage(named: "FamilyMember_CoronaTest_invalid_expired")
		isDisclosureIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = false

		switch coronaTest.type {
		case .pcr:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.expiredPCRButton
		case .antigen:
			accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.expiredAntigenButton
		}
	}

	private func configureTestResultOutdated() {
		description = AppStrings.Home.TestResult.Outdated.description
		footnote = nil
		buttonTitle = AppStrings.Home.TestResult.Button.hideTest
		image = UIImage(named: "FamilyMember_CoronaTest_outdated")
		isDisclosureIndicatorHidden = true
		isUserInteractionEnabled = true
		isCellTappable = false
		accessibilityIdentifier = AccessibilityIdentifiers.Home.TestResultCell.outdatedAntigenButton
	}

}
