//
// 🦠 Corona-Warn-App
//

/// If the risk provider is running in manual mode then the manual exposure detection state tells you whether or not requestRisk(…) will trigger an exposure detection when called.
enum ManualExposureDetectionState {
	/// If the state is `possible` then calling requestRisk(…) will trigger a new exposure detection and risk calculation.
	case possible
	/// If the state is `waiting` then calling requestRisk(…) will return the risk of the previous exposure detection.
	case waiting
}
