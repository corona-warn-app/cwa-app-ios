//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import ExposureNotification

final class HomeInteractorTests: XCTestCase {

	func test_When_updateEnStateIsCalledImmediatelyAfterInit_Then_HomeInteractorDoesNotCrash() {
		let keys = [ENTemporaryExposureKey()]
		let keysRetrieval = MockDiagnosisKeysRetrieval(diagnosisKeysResult: (keys, nil))
		let client = ClientMock()
		let store = MockTestStore()
		store.registrationToken = "dummyRegistrationToken"
		let appConfigurationProvider = CachedAppConfigurationMock()

		let service = ENAExposureSubmissionService(diagnosisKeysRetrieval: keysRetrieval, appConfigurationProvider: appConfigurationProvider, client: client, store: store, warnOthersReminder: WarnOthersReminder(store: store))
		let delegate = HomeViewControllerDelegateDummy()
		let exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		let homeController = HomeViewController(
			delegate: delegate,
			exposureManagerState: exposureManagerState,
			initialEnState: .enabled,
			exposureSubmissionService: service
		)

		let enState = ENStateHandler.State.enabled
		let homeInteractorState = HomeInteractor.State(riskState: .inactive, exposureManagerState: exposureManagerState, enState: enState)
		let homeInteractor = HomeInteractor(
			homeViewController: homeController,
			state: homeInteractorState,
			exposureSubmissionService: service,
			warnOthersReminder: WarnOthersReminder(store: store)
		)

		homeInteractor.updateEnState(.enabled)
	}
}

private final class HomeViewControllerDelegateDummy: HomeViewControllerDelegate {
	func showRiskLegend() { }
	func showExposureNotificationSetting(enState: ENStateHandler.State) { }
	func showExposureDetection(state: HomeInteractor.State, activityState: RiskProviderActivityState) { }
	func setExposureDetectionState(state: HomeInteractor.State, activityState: RiskProviderActivityState) { }
	func showExposureSubmission(with result: TestResult?) { }
	func showDiary() { }
	func showInviteFriends() { }
	func showWebPage(from viewController: UIViewController, urlString: String) { }
	func showAppInformation() { }
	func showSettings(enState: ENStateHandler.State) { }
	func addToEnStateUpdateList(_ anyObject: AnyObject?) { }
}
