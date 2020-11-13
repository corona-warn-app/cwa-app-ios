//
// 🦠 Corona-Warn-App
//

/// If the risk provider is running in manual mode then the manual exposure detection state tells you whether or not requestRisk(…) will trigger an exposure detection when called.
enum ManualExposureDetectionState {
	/// If the state is `possible` then calling requestRisk(…) will trigger an exposure detection when called.
	case possible
	/// If the state is `waiting` then calling requestRisk(…) will used the cached summary to do a risk detection.
	case waiting
}
