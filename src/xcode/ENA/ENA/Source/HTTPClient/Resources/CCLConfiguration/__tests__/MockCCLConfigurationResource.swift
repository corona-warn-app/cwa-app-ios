//
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

class MockCCLConfigurationResource: CCLConfigurationResource {

	// MARK: - Init

	init(defaultModel: CCLConfigurationReceiveModel?) {
		self.defaultReceiveModel = defaultModel
	}

	// MARK: - Protocol Resource

	override func defaultModel() -> CCLConfigurationReceiveModel? {
		defaultReceiveModel
	}

	// MARK: - Private

	let defaultReceiveModel: CCLConfigurationReceiveModel?

}
