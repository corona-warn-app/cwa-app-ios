////
// 🦠 Corona-Warn-App
//

import Foundation
@testable import ENA

final class MigrationStub: Migration {

	private let migration: () -> Void

	init(version: Int, migration: @escaping () -> Void) {
		self.version = version
		self.migration = migration
	}

	// MARK: - Protocol Migration

	var version = 0

	func execute() throws {
		migration() // always succeeds!
	}
}
