//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit
import OpenCombine

class FamilyTestsHomeCellViewModel {

	// MARK: - Init

	init(
		familyMemberCoronaTestService: FamilyMemberCoronaTestServiceProviding,
		onUpdate: @escaping () -> Void
	) {
		self.familyMemberCoronaTestService = familyMemberCoronaTestService

		familyMemberCoronaTestService.coronaTests
			.sink { [weak self] _ in
				let unseenNewsCount = self?.familyMemberCoronaTestService.unseenNewsCount ?? 0

				if self?.badgeCount.value != unseenNewsCount {
					self?.badgeCount.value = unseenNewsCount
					onUpdate()
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

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
