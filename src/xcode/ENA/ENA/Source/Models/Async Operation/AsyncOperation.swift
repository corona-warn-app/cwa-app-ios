////
// 🦠 Corona-Warn-App
//

import Foundation

class AsyncOperation: Operation {
		
	// MARK: - Overrides
	
	override var isReady: Bool {
		return state == .ready && super.isReady
	}
	
	override var isExecuting: Bool {
		return state == .executing
	}
	
	override var isFinished: Bool {
		return state == .finished
	}
	
	override func start() {
		if isCancelled {
			finish()
			return
		}
		state = .executing
		main()
	}
	
	override func main() {
		fatalError("Developer error. Subclass must override this function and execute main code here. Call `finish()` when task is complete.")
	}
	
	override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
		if ["isReady", "isFinished", "isExecuting"].contains(key) {
			return [#keyPath(state)]
		}
		return super.keyPathsForValuesAffectingValue(forKey: key)
	}
	
	// MARK: - Internal
	
	func finish() {
		if !isFinished {
			state = .finished
		}
	}
	
	static func serialQueue(named: String) -> OperationQueue {
		let queue = OperationQueue()
		queue.name = named
		queue.maxConcurrentOperationCount = 1
		return queue
	}
	
	// MARK: - Private
	
	@objc
	private enum State: Int {
		case ready
		case executing
		case finished
	}
	
	@objc
	private
	dynamic var state: State {
		get {
			return stateQueue.sync {
				rawState
			}
		}
		set {
			stateQueue.sync(flags: .barrier) {
				rawState = newValue
			}
		}
	}
	
	private let stateQueue = DispatchQueue(label: "AsyncOperation.stateQueue", attributes: .concurrent)
	
	private var rawState: State = .ready
}
