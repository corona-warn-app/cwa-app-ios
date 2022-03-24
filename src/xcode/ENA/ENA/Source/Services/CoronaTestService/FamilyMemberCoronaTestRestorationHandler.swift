//
// 🦠 Corona-Warn-App
//

struct FamilyMemberCoronaTestRestorationHandler: FamilyMemberTestRestorationHandling {

	// MARK: - Init

	init(service: FamilyMemberCoronaTestServiceProviding) {
		restore = { coronaTest in
			service.reregister(coronaTest: coronaTest)
		}
	}

	// MARK: - Protocol FamilyMemberTestRestorationHandling

	let restore: ((FamilyMemberCoronaTest) -> Void)

}
