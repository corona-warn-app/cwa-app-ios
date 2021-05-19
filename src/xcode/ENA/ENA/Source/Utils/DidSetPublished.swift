////
// 🦠 Corona-Warn-App
//

import OpenCombine

@propertyWrapper
class DidSetPublished<Value> {

	init(wrappedValue value: Value) {
		projectedValue = CurrentValueSubject(value)
	}

	var wrappedValue: Value {
		get {
			projectedValue.value
		}
		set {
			projectedValue.value = newValue
		}
	}

	var projectedValue: OpenCombine.CurrentValueSubject<Value, Never>

}
