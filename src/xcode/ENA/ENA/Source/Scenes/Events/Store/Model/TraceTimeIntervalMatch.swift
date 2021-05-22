////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

import Foundation

struct TraceTimeIntervalMatch {

	let id: Int
	let checkinId: Int
	let traceWarningPackageId: Int
	let traceLocationId: Data
	let transmissionRiskLevel: Int
	let startIntervalNumber: Int
	let endIntervalNumber: Int
}
