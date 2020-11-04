import Foundation

final class CancellationToken {
	// MARK: Types
	typealias Handler = () -> Void

	// MARK: Creating a Cancellation Token
	init(onCancel: @escaping Handler) {
		self.onCancel = onCancel
		isCancelled = false
	}

	// MARK: Properties
	let onCancel: Handler
	private var isCancelled: Bool

	// MARK: Working with the Cancellation Token
	func cancel() {
		precondition(
			isCancelled == false,
			"Cancelling an already cancelled operation is not supported and indicates a programmer error."
		)
		isCancelled = true
		onCancel()
	}
}
