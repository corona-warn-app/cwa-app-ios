//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import AVFoundation

class FamilyMemberCoronaTestsViewModel {

	// MARK: - Init

	init(
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		appConfigurationProvider: AppConfigurationProviding,
		onCoronaTestCellTap: @escaping (FamilyMemberCoronaTest) -> Void,
		onLastDeletion: @escaping () -> Void
	) {
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.appConfigurationProvider = appConfigurationProvider
		self.onCoronaTestCellTap = onCoronaTestCellTap

		familyMemberCoronaTestService.coronaTests
			.sink { [weak self] in
				self?.update(from: $0)

				if $0.isEmpty {
					onLastDeletion()
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case coronaTests
	}

	let triggerReload = CurrentValueSubject<Bool, Never>(false)
	let isUpdatingTestResults = CurrentValueSubject<Bool, Never>(false)
	let testResultLoadingError = CurrentValueSubject<CoronaTestServiceError?, Never>(nil)

	var onUpdate: (() -> Void)?

	var coronaTestCellModels: [FamilyMemberCoronaTestCellModel] = []

	var numberOfSections: Int {
		Section.allCases.count
	}

	var isEmpty: Bool {
		numberOfRows(in: Section.coronaTests.rawValue) == 0
	}

	func numberOfRows(in section: Int) -> Int {
		switch Section(rawValue: section) {
		case .coronaTests:
			return coronaTestCellModels.count
		case .none:
			fatalError("Invalid section")
		}
	}

	func canEditRow(at indexPath: IndexPath) -> Bool {
		return indexPath.section == Section.coronaTests.rawValue
	}

	func didTapCoronaTestCell(at indexPath: IndexPath) {
		guard indexPath.section == Section.coronaTests.rawValue else {
			fatalError("didTapCoronaTestCell can only be called from the coronaTests section")
		}

		let coronaTest = coronaTestCellModels[indexPath.row].coronaTest
		guard let updatedCoronaTest = familyMemberCoronaTestService.upToDateTest(for: coronaTest) else {
			return
		}

		if updatedCoronaTest.isOutdated || updatedCoronaTest.testResult == .expired {
			return
		}

		onCoronaTestCellTap(updatedCoronaTest)
	}

	func didTapCoronaTestCellButton(at indexPath: IndexPath) {
		guard indexPath.section == Section.coronaTests.rawValue else {
			fatalError("didTapEntryCell can only be called from the coronaTests section")
		}

		familyMemberCoronaTestService.moveTestToBin(coronaTestCellModels[indexPath.row].coronaTest)
	}

	func removeEntry(at indexPath: IndexPath) {
		familyMemberCoronaTestService.moveTestToBin(coronaTestCellModels[indexPath.row].coronaTest)
	}

	func removeAll() {
		familyMemberCoronaTestService.moveAllTestsToBin()
	}

	func markAllAsSeen() {
		familyMemberCoronaTestService.evaluateShowingAllTests()
	}

	func updateTestResults() {
		isUpdatingTestResults.value = true

		familyMemberCoronaTestService.updateTestResults(
			presentNotification: false
		) { [weak self] result in
			guard let self = self else {
				Log.error("Could not create strong self")
				return
			}

			self.isUpdatingTestResults.value = false

			if case .failure(let error) = result {
				switch error {
				case .noCoronaTestOfRequestedType, .noRegistrationToken, .testExpired:
					// Errors because of no registered corona tests or expired tests are ignored
					break
				case .responseFailure(let responseFailure):
					switch responseFailure {
					case .fakeResponse:
						Log.info("Fake response - skip it as it's not an error")
					case .noResponse:
						Log.info("Tried to get test result but no response was received")
					default:
						self.testResultLoadingError.value = error
					}
				case .teleTanError, .registrationTokenError, .malformedDateOfBirthKey, .testResultError:
					self.testResultLoadingError.value = error
				}
			}
		}
	}

	// MARK: - Private

	private let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	private let appConfigurationProvider: AppConfigurationProviding
	private let onCoronaTestCellTap: (FamilyMemberCoronaTest) -> Void

	private var subscriptions: [AnyCancellable] = []

	private func update(from coronaTests: [FamilyMemberCoronaTest]) {
		guard coronaTests.map({ $0.qrCodeHash }) != coronaTestCellModels.map({ $0.coronaTest.qrCodeHash }) else {
			// Nothing to do as tests stayed the same, cells will update themselves
			return
		}

		coronaTestCellModels = coronaTests
			.sorted {
				$0.testDate > $1.testDate
			}
			.map { coronaTest in
				FamilyMemberCoronaTestCellModel(
					coronaTest: coronaTest,
					familyMemberCoronaTestService: familyMemberCoronaTestService,
					appConfigurationProvider: appConfigurationProvider,
					onUpdate: { [weak self] in
						self?.onUpdate?()
					}
				)
			}

		triggerReload.value = true
	}

}
