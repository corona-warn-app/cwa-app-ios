//
// 🦠 Corona-Warn-App
//

struct TestRestorationHandler: TestRestorationHandling {

	// MARK: - Init

	init(service: CoronaTestService) {
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

	// MARK: - Protocol TestRestorationHandling

	let canRestore: ((CoronaTest) -> Result<Void, TestRestorationError>)
	let restore: ((CoronaTest) -> Void)

}
