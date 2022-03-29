//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import AVFoundation

class FamilyMemberCoronaTestsViewModel {

	// MARK: - Init

	init(
		familyMemberCoronaTestService: FamilyMemberCoronaTestService,
		onCoronaTestCellTap: @escaping (FamilyMemberCoronaTest) -> Void,
		onLastDeletion: @escaping () -> Void
	) {
		self.familyMemberCoronaTestService = familyMemberCoronaTestService
		self.onCoronaTestCellTap = onCoronaTestCellTap

		familyMemberCoronaTestService.coronaTests
			.sink { [weak self] in
				guard !$0.isEmpty else {
					onLastDeletion()
					return
				}

				self?.update(from: $0)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	enum Section: Int, CaseIterable {
		case coronaTests
	}

	@OpenCombine.Published var triggerReload: Bool = false

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

		onCoronaTestCellTap(coronaTestCellModels[indexPath.row].coronaTest)
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

	// MARK: - Private

	private let familyMemberCoronaTestService: FamilyMemberCoronaTestService
	private let onCoronaTestCellTap: (FamilyMemberCoronaTest) -> Void

	private var subscriptions: [AnyCancellable] = []

	private func update(from coronaTests: [FamilyMemberCoronaTest]) {
		guard coronaTests.map({ $0.qrCodeHash }) != coronaTestCellModels.map({ $0.coronaTest.qrCodeHash }) else {
			// Nothing to do as tests stayed the same, cells will update themselves
			return
		}

		coronaTestCellModels = coronaTests.map { coronaTest in
			FamilyMemberCoronaTestCellModel(
				coronaTest: coronaTest,
				familyMemberCoronaTestService: familyMemberCoronaTestService,
				onUpdate: { [weak self] in
					self?.onUpdate?()
				}
			)
		}

		triggerReload = true
	}

}
