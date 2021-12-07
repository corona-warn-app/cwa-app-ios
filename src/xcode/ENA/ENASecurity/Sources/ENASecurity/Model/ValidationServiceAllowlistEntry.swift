//
// 🦠 Corona-Warn-App
//

import Foundation

public struct ValidationServiceAllowlistEntry: Codable {

	// MARK: - Init
	
	public init(
		serviceProvider: String,
		hostname: String,
		fingerprint256: String
	) {
		self.serviceProvider = serviceProvider
		self.hostname = hostname
		self.fingerprint256 = fingerprint256
	}
	
	// MARK: - Internal

	// Display name for the provider of the Validation Service
    public let serviceProvider: String
	// The hostname of the Validation Service
    public let hostname: String
	// The SHA-256 fingerprint of the certificate of the Validation Service
	public let fingerprint256: String
}
