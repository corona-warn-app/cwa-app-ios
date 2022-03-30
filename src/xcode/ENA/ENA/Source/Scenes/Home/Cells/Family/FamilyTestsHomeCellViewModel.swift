//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class FamilyTestsHomeCellViewModel: Equatable {

	static func == (lhs: FamilyTestsHomeCellViewModel, rhs: FamilyTestsHomeCellViewModel) -> Bool {
		return true
	}

	// MARK: - Init

	init(
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding
	) {
		self.familyMemberCoronaTestService = familyMemberCoronaTestService

		familyMemberCoronaTestService.coronaTests.sink { [weak self] _ in
			self?.badgeCount.value = self?.familyMemberCoronaTestService.unseenNewsCount ?? 0
		}
		.store(in: &subscriptions)
	}

	// MARK: - Internal

	let titleText: String = AppStrings.Home.familyTestTitle

 	var badgeCount: CurrentValueSubject<Int, Never> = CurrentValueSubject(0)

	var badgeText: String? {
		guard badgeCount.value > 0 else { return nil }
		return "\(badgeCount.value)"
	}

	var detailText: String? {
		badgeCount.value > 0 ? AppStrings.Home.familyTestDetail : nil
	}

	var isDetailsHidden: Bool {
		detailText == nil
	}

	// MARK: - Private

	private let familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding

	private var subscriptions = Set<AnyCancellable>()

}
