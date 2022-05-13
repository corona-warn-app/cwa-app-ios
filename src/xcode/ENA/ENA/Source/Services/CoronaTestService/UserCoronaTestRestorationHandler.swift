//
// 🦠 Corona-Warn-App
//

struct UserCoronaTestRestorationHandler: UserTestRestorationHandling {

	// MARK: - Init

	init(service: CoronaTestServiceProviding) {
		canRestore = { coronaTest in
			if service.coronaTest(ofType: coronaTest.type) == nil {
				return .success(())
			} else {
				return .failure(.testTypeAlreadyRegistered)
			}
		}

		restore = { coronaTest in
			if service.coronaTest(ofType: coronaTest.type) != nil {
				service.moveTestToBin(coronaTest.type)
			}

			service.reregister(coronaTest: coronaTest)
		}
	}

	// MARK: - Protocol UserTestRestorationHandling

	let canRestore: ((UserCoronaTest) -> Result<Void, TestRestorationError>)
	let restore: ((UserCoronaTest) -> Void)

}
