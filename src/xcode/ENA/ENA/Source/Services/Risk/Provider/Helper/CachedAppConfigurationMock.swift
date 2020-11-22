//
// 🦠 Corona-Warn-App
//

import Foundation
import Combine
import ZIPFoundation

#if DEBUG
final class CachedAppConfigurationMock: AppConfigurationProviding {

	private let config: SAP_Internal_V2_ApplicationConfigurationIOS

	init(with config: SAP_Internal_V2_ApplicationConfigurationIOS? = nil) {
		guard
			let url = Bundle.main.url(forResource: "default_app_config_18", withExtension: ""),
			let data = try? Data(contentsOf: url),
			let zip = Archive(data: data, accessMode: .read),
			let staticConfig = try? zip.extractAppConfiguration() else {
			fatalError("Could not fetch static app config")
		}
		self.config = config ?? staticConfig
	}

	func appConfiguration(forceFetch: Bool) -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never> {
		return Just(config)
			.receive(on: DispatchQueue.main)
			.eraseToAnyPublisher()
	}

	func appConfiguration() -> AnyPublisher<SAP_Internal_V2_ApplicationConfigurationIOS, Never> {
		return appConfiguration(forceFetch: false)
	}
}
#endif
