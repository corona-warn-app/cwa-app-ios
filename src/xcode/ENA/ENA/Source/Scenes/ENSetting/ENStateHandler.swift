//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

protocol ENStateHandlerUpdating: AnyObject {
	func updateEnState(_ state: ENStateHandler.State)
}


final class ENStateHandler {

	private var currentState: State! {
		didSet {
			stateDidChange()
		}
	}

	var state: ENStateHandler.State {
		currentState
	}

	private weak var delegate: ENStateHandlerUpdating?
	private var latestExposureManagerState: ExposureManagerState
	
	init(
		initialExposureManagerState: ExposureManagerState,
		delegate: ENStateHandlerUpdating
	) {
		self.delegate = delegate
		self.latestExposureManagerState = initialExposureManagerState
		self.currentState = determineCurrentState(from: latestExposureManagerState)
	}

	private func stateDidChange() {
		guard let delegate = delegate else {
			fatalError("Delegate is nil. It should not happen.")
		}
		delegate.updateEnState(currentState)
	}

	private func determineCurrentState(from enManagerState: ExposureManagerState) -> State {

		switch enManagerState.status {
		case .active:
			return .enabled
		case .bluetoothOff:
			guard !enManagerState.enabled == false else {
				return .disabled
			}
			return .bluetoothOff
		case .disabled:
			return .disabled
		case .restricted:
			return differentiateWithAuthorizationStatus()
		case .unknown:
			return .disabled
		case .paused:
			return .disabled
		case .unauthorized:
			return differentiateWithAuthorizationStatus()
		@unknown default:
			Log.error("New state was added that is not being covered by ENStateHandler", log: .api)
			return .unknown
		}
	}

	private func differentiateWithAuthorizationStatus() -> State {
		switch ENManager.authorizationStatus {
		case .notAuthorized:
			return .notAuthorized
		case .restricted:
			return .restricted
		case .unknown:
			return .unknown
		case .authorized:
			return .notActiveApp
		@unknown default:
			Log.error("New state was added that is not being covered by ENStateHandler", log: .api)
			return .unknown
		}
	}
}

extension ENStateHandler: ExposureStateUpdating {
	func updateExposureState(_ state: ExposureManagerState) {
		latestExposureManagerState = state
		currentState = determineCurrentState(from: state)
	}
}
