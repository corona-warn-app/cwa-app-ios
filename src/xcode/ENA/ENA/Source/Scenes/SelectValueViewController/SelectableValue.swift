//
// 🦠 Corona-Warn-App
//

struct SelectableValue: Comparable {
	
		// MARK: - Internal
	let title: String
	let subtitle: String?
	let identifier: String?
	let isEnabled: Bool
	
		// MARK: - Init
	init(title: String, subtitle: String? = nil, identifier: String? = nil, isEnabled: Bool = true) {
		self.title = title
		self.subtitle = subtitle
		self.identifier = identifier
		self.isEnabled = isEnabled
	}
	
	// MARK: - Protocol Comparable

	static func < (lhs: SelectableValue, rhs: SelectableValue) -> Bool {
		return lhs.title < rhs.title
	}

}
