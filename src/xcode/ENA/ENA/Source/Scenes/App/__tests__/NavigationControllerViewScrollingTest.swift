//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

// Hint: if this test turns out fragile, try to increase the timing in UINavigationController.scrollViewToTop

private protocol Scrolling {
	func scrollToBottom()
}

private typealias ScrollingViewController = UIViewController & Scrolling

class NavigationControllerViewScrollingTest: CWATestCase {
	typealias Predicate = ((UINavigationController) -> Bool)

    override func setUpWithError() throws {
		try super.setUpWithError()
    }

    override func tearDownWithError() throws {
		try super.tearDownWithError()
    }

    func test_thatLargeTableShowsLargeTitle() {
		performTestWith(
			ScrollingTableVC(numberOfRows: 30, hasLargeTitle: true),
			precondition: hasNarrowNavigationBar,
			postcondition: hasWideNavigationBar)
    }

	func test_thatSmallTableShowsLargeTitle() {
		performTestWith(
			ScrollingTableVC(numberOfRows: 5, hasLargeTitle: true),
			precondition: hasWideNavigationBar,
			postcondition: hasWideNavigationBar)
	}

	func test_thatEmptyTableDoesNotCrash() {
		performTestWith(
			ScrollingTableVC(numberOfRows: 0, hasLargeTitle: true),
			precondition: hasWideNavigationBar,
			postcondition: hasWideNavigationBar)
	}

	func test_thatNormalTitleIsNotLost() {
		performTestWith(
			ScrollingTableVC(numberOfRows: 30, hasLargeTitle: false),
			precondition: hasNarrowNavigationBar,
			postcondition: hasNarrowNavigationBar)
	}

	func test_thatDynamicTableShowsLargeTitle() {
		let dynamicVC = ScrollingDynTableVC()
		performTestWith(
			dynamicVC,
			precondition: hasNarrowNavigationBar,
			postcondition: hasWideNavigationBar)
	}
	
	func test_thatScrollViewShowsLargeTitle() {
		let scrollVC = ScrollingNoTableVC()
		performTestWith(
			scrollVC,
			precondition: hasNarrowNavigationBar,
			postcondition: hasWideNavigationBar)
	}

	func test_thatVCWithoutScrollViewDoesNotCrash() {
		let vc = FakeScrollingViewController()
		performTestWith(
			vc,
			precondition: hasWideNavigationBar,
			postcondition: hasWideNavigationBar)
	}

	// MARK: - Private
	private func performTestWith(
		_ viewController: ScrollingViewController,
		precondition: @escaping Predicate,
		postcondition: @escaping Predicate
	) {
		// GIVEN
		var window: UIWindow! = UIWindow(frame: UIScreen.main.bounds)
		window.makeKeyAndVisible()
		let sut = UINavigationController(rootViewController: viewController)
		sut.loadViewIfNeeded()
		window.rootViewController = sut
		sut.navigationBar.prefersLargeTitles = true
		
		let didFinishTestExpectation = expectation(description: "Wait for the animations before ending the test")

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {		// wait for animated viewWillAppear
			viewController.scrollToBottom()
			DispatchQueue.main.async {		// wait for scrollToBottom (without animation)
				XCTAssertTrue(precondition(sut))
				// WHEN
				sut.scrollEmbeddedViewToTop()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {		// wait for animated scrollEmbeddedViewToTop
					// THEN
					XCTAssertTrue(postcondition(sut))
					didFinishTestExpectation.fulfill()
				}
			}
		}

		waitForExpectations(timeout: .short)
		window = nil
	}

	private func hasWideNavigationBar(_ navigationController: UINavigationController) -> Bool {
		navigationController.navigationBar.bounds.height > 95
	}

	private func hasNarrowNavigationBar(_ navigationController: UINavigationController) -> Bool {
		navigationController.navigationBar.bounds.height < 45
	}
}

private class ScrollingTableVC: UITableViewController, Scrolling {

	// MARK: - Init

	init(
		numberOfRows: Int,
		hasLargeTitle: Bool
	) {
		self.numberOfRows = numberOfRows
		self.hasLargeTitle = hasLargeTitle
		super.init(style: .plain)
		self.title = "Title"
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
	}
	
	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = self.title
		navigationItem.largeTitleDisplayMode = self.hasLargeTitle ? .always : .never
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.sizeToFit()
	}
	
	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		numberOfRows
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
		cell.textLabel?.text = String(indexPath.row)
		return cell
	}

	// MARK: - Protocol Scrolling
	func scrollToBottom() {
		let lastRow = tableView(tableView, numberOfRowsInSection: 0) - 1
		guard lastRow >= 0 else {
			return
		}
		tableView.scrollToRow(at: IndexPath(indexes: [0, lastRow]), at: .bottom, animated: false)
	}

	// MARK: - Private
	let hasLargeTitle: Bool
	let numberOfRows: Int
	let cellReuseIdentifier = "cell"
}

private class ScrollingDynTableVC: DynamicTableViewController, Scrolling {

	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = "Title"
		tableView.reloadData() // Force a reload that new ViewModel gets used
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.sizeToFit()
	}

	// MARK: - Protocol Scrolling

	func scrollToBottom() {
		let lastRow = tableView(tableView, numberOfRowsInSection: 0) - 1
		guard lastRow >= 0 else {
			return
		}
		tableView.scrollToRow(at: IndexPath(indexes: [0, lastRow]), at: .bottom, animated: false)
	}

	// MARK: - Private
	private func configure() {
		var cells: [DynamicCell] = []
		for _ in 0 ..< 30 {
			cells += [.dynamicType(text: "Foo")]
		}
		let section = DynamicSection.section(cells: cells)
		dynamicTableViewModel = DynamicTableViewModel([section])
	}
}

private class ScrollingNoTableVC: ScrollingViewController {

	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = ColorCompatibility.systemBackground
		view.addSubview(scrollview)
		configureScrollView()
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = "Title"
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.sizeToFit()
	}

	// MARK: - Protocol Scrolling

	func scrollToBottom() {
		scrollview.scrollRectToVisible(CGRect(x: 0, y: scrollview.contentSize.height - 1, width: 1, height: 1), animated: false)
	}

	// MARK: - Private
	private let scrollview = UIScrollView()
	private let logoImage = UIImage(imageLiteralResourceName: "Corona-Warn-App").withRenderingMode(.alwaysOriginal)

	private func makeImageViewElement() -> [UIImageView] {
		let logoImageView = UIImageView(image: logoImage)
		logoImageView.tintColor = .enaColor(for: .textContrast)
		logoImageView.contentMode = .left
		return [logoImageView]
	}

	private func configureScrollView() {
		var arrangedSubviews: [UIImageView] = []
		for _ in 0 ..< 30 {
			arrangedSubviews += makeImageViewElement()
		}

		let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = 10

		scrollview.addSubview(stackView)
		scrollview.translatesAutoresizingMaskIntoConstraints = false

		// layout constraints
		let heightAnchor = stackView.heightAnchor.constraint(equalTo: scrollview.heightAnchor)
		heightAnchor.priority = .defaultLow

		NSLayoutConstraint.activate([
			scrollview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollview.topAnchor.constraint(equalTo: view.topAnchor),
			scrollview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: 10),
			stackView.trailingAnchor.constraint(equalTo: scrollview.trailingAnchor, constant: -10),
			stackView.topAnchor.constraint(equalTo: scrollview.topAnchor, constant: 10),
			stackView.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
			stackView.widthAnchor.constraint(equalTo: scrollview.widthAnchor, constant: -20),
			heightAnchor
		])
	}
}

private class FakeScrollingViewController: ScrollingViewController {
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .red
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = "Title"
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.sizeToFit()
	}

	// MARK: - Protocol Scrolling

	func scrollToBottom() {
	}
}
