//
// 🦠 Corona-Warn-App
//

extension SAP_Internal_Stats_LinkCard {
	static let bmgPandemicRadarURLMock: String = "https://corona-pandemieradar.de/de"
	
	/**
	 Returns a mocked `SAP_Internal_Stats_LinkCard`
	 - Parameters:
		- cardID: ID of the Link Card. Part of `SAP_Internal_Stats_CardHeader`.
		- updatedAt: Part of `SAP_Internal_Stats_CardHeader`
		- url: The url the should be open. Default value: BMG pandamic radar url.
	 */
	static func mock(
		cardID: Int32 = 0,
		updatedAt: Int64 = 0,
		url: String = Self.bmgPandemicRadarURLMock
	) -> SAP_Internal_Stats_LinkCard {
		var cardHeader = SAP_Internal_Stats_CardHeader()
		cardHeader.cardID = cardID
		cardHeader.updatedAt = updatedAt
		
		var card = SAP_Internal_Stats_LinkCard()
		card.header = cardHeader
		card.url = url
		return card
	}
}
