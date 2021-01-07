//
// 🦠 Corona-Warn-App
//

import Foundation

final class RiskConsumer: NSObject {

	// MARK: Creating a Consumer

	init(targetQueue: DispatchQueue = .main) {
		self.targetQueue = targetQueue
	}

	// MARK: Properties

	/// The queue `didCalculateRisk` will be called on. Defaults to `.main`.
	let targetQueue: DispatchQueue

	/// Called when the risk level changed
	var didCalculateRisk: ((Risk) -> Void) = { _ in }

	/// Called when the risk calculation fails.
	var didFailCalculateRisk: (RiskProviderError) -> Void = { _ in }

	/// Called when loading status changed
	var didChangeActivityState: ((_ activityState: RiskProviderActivityState) -> Void)?

	/// Called when risk providing configuration changed
	var didChangeRiskProvidingConfiguration: ((_ riskProvidingConfiguration: RiskProvidingConfiguration) -> Void)?

}
