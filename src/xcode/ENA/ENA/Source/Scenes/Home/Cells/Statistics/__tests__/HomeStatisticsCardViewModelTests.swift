//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class HomeStatisticsCardViewModelTests: CWATestCase {

	func testFormattedSmallValueWithoutDecimals() {
		checkFormattedValue(value: 0.1798, decimals: 0, expectedString: "0", expectedStringWithPercent: "18%")
	}

	func testFormattedSmallValueWithNegativeDecimalsIsHandledAsZeroDecimals() {
		checkFormattedValue(value: 0.1798, decimals: -1, expectedString: "0", expectedStringWithPercent: "18%")
	}

	func testFormattedSmallValueWithDecimals() {
		checkFormattedValue(value: 0.1798, decimals: 2, expectedString: "0,18", expectedStringWithPercent: "17,98%")
	}

	func testFormattedMediumValueWithoutDecimals() {
		checkFormattedValue(value: 17.98, decimals: 0, expectedString: "18", expectedStringWithPercent: "1.798%")
	}

	func testFormattedMediumValueWithNegativeDecimalsIsHandledAsZeroDecimals() {
		checkFormattedValue(value: 17.98, decimals: -1, expectedString: "18", expectedStringWithPercent: "1.798%")
	}

	func testFormattedMediumValueWithDecimals() {
		checkFormattedValue(value: 17.98, decimals: 2, expectedString: "17,98", expectedStringWithPercent: "1.798%")
	}

	func testVeryHighFormattedValue() {
		checkFormattedValue(value: 10_000_000, decimals: 2, expectedString: "10.000.000,00", expectedStringWithPercent: "1.000.000.000%")
	}

	func testTrendImageAndAccessibilityLabelForIncreasingTrend() {
		checkTrendImageAndAccessibilityLabel(
			trend: .increasing,
			expectedImage: UIImage(named: "Pfeil_steigend_plain"),
			expectedAccessibilityLabel: AppStrings.Statistics.Card.trendIncreasing
		)
	}

	func testTrendImageAndAccessibilityLabelForDecreasingTrend() {
		checkTrendImageAndAccessibilityLabel(
			trend: .decreasing,
			expectedImage: UIImage(named: "Pfeil_sinkend_plain"),
			expectedAccessibilityLabel: AppStrings.Statistics.Card.trendDecreasing
		)
	}

	func testTrendImageAndAccessibilityLabelForStableTrend() {
		checkTrendImageAndAccessibilityLabel(
			trend: .stable,
			expectedImage: UIImage(named: "Pfeil_stabil_plain"),
			expectedAccessibilityLabel: AppStrings.Statistics.Card.trendStable
		)
	}

	func testTrendImageAndAccessibilityLabelForUnspecifiedTrend() {
		checkTrendImageAndAccessibilityLabel(
			trend: .unspecifiedTrend,
			expectedImage: nil,
			expectedAccessibilityLabel: nil
		)
	}

	func testTrendImageAndAccessibilityLabelForUnrecognizedTrend() {
		checkTrendImageAndAccessibilityLabel(
			trend: .UNRECOGNIZED(4),
			expectedImage: nil,
			expectedAccessibilityLabel: nil
		)
	}

	func testTrendImageTintColorAndAccessibilityValueForNegativeTrendSemantic() {
		checkTrendImageTintColorAndAccessibilityValue(
			trendSemantic: .negative,
			expectedColor: .enaColor(for: .riskHigh),
			expectedAccessibilityValue: AppStrings.Statistics.Card.trendSemanticNegative
		)
	}

	func testTrendImageTintColorAndAccessibilityValueForNeutralTrendSemantic() {
		checkTrendImageTintColorAndAccessibilityValue(
			trendSemantic: .neutral,
			expectedColor: .enaColor(for: .riskNeutral),
			expectedAccessibilityValue: AppStrings.Statistics.Card.trendSemanticNeutral
		)
	}

	func testTrendImageTintColorAndAccessibilityValueForPositiveTrendSemantic() {
		checkTrendImageTintColorAndAccessibilityValue(
			trendSemantic: .positive,
			expectedColor: .enaColor(for: .riskLow),
			expectedAccessibilityValue: AppStrings.Statistics.Card.trendSemanticPositive
		)
	}

	func testTrendImageTintColorAndAccessibilityValueForUnspecifiedTrendSemantic() {
		checkTrendImageTintColorAndAccessibilityValue(
			trendSemantic: .unspecifiedTrendSemantic,
			expectedColor: nil,
			expectedAccessibilityValue: nil
		)
	}

	func testTrendImageTintColorAndAccessibilityValueForUnrecognizedTrendSemantic() {
		checkTrendImageTintColorAndAccessibilityValue(
			trendSemantic: .UNRECOGNIZED(4),
			expectedColor: nil,
			expectedAccessibilityValue: nil
		)
	}
	
	// MARK: - At least once vaccinated Card
	
	func testAtLeastOnceVaccinatedCardStaticValues() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 5,
				keyFigures: [keyFigure(rank: .secondary), keyFigure(rank: .tertiary)]
			)
		)

		XCTAssertEqual(viewModel.illustrationImage, UIImage(named: "AtleastOneVaccinated"))
		XCTAssertEqual(viewModel.title, AppStrings.Statistics.Card.AtleastOneVaccinated.title)
		XCTAssertEqual(viewModel.subtitle, AppStrings.Statistics.Card.fromNationWide)
		XCTAssertEqual(viewModel.primarySubtitle, AppStrings.Statistics.Card.AtleastOneVaccinated.primarySubtitle)
		XCTAssertEqual(viewModel.secondaryTitle, AppStrings.Statistics.Card.AtleastOneVaccinated.secondaryLabelTitle)
		XCTAssertEqual(viewModel.tertiaryTitle, AppStrings.Statistics.Card.AtleastOneVaccinated.tertiaryLabelTitle)
	}
	
	func testAtLeastOnceVaccinatedCardPrimaryTitleToday() throws {
		let today = Date()

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 5,
				updatedAt: Int64(today.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis heute")
	}

	func testAtLeastOnceVaccinatedCardPrimaryTitleYesterday() throws {
		let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()))

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 5,
				updatedAt: Int64(yesterday.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis Gestern")
	}

	func testAtLeastOnceVaccinatedCardPrimaryTitleOtherDate() throws {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 5,
				updatedAt: 1610891698, // 2021-01-17
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis 17.01.2021")
	}
	
	// MARK: - Fully vaccinated Card
	
	func testFullyVaccinatedCardStaticValues() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 6,
				keyFigures: [keyFigure(rank: .secondary), keyFigure(rank: .tertiary)]
			)
		)

		XCTAssertEqual(viewModel.illustrationImage, UIImage(named: "FullyVaccinated"))
		XCTAssertEqual(viewModel.title, AppStrings.Statistics.Card.FullyVaccinated.title)
		XCTAssertEqual(viewModel.subtitle, AppStrings.Statistics.Card.fromNationWide)
		XCTAssertEqual(viewModel.primarySubtitle, AppStrings.Statistics.Card.FullyVaccinated.primarySubtitle)
		XCTAssertEqual(viewModel.secondaryTitle, AppStrings.Statistics.Card.FullyVaccinated.secondaryLabelTitle)
		XCTAssertEqual(viewModel.tertiaryTitle, AppStrings.Statistics.Card.FullyVaccinated.tertiaryLabelTitle)
	}
	
	func testFullyVaccinatedCardPrimaryTitleToday() throws {
		let today = Date()

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 6,
				updatedAt: Int64(today.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis heute")
	}

	func testFullyVaccinatedCardPrimaryTitleYesterday() throws {
		let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()))

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 6,
				updatedAt: Int64(yesterday.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis Gestern")
	}

	func testFullyVaccinatedCardPrimaryTitleOtherDate() throws {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 6,
				updatedAt: 1610891698, // 2021-01-17
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis 17.01.2021")
	}
	
	// MARK: - Doses Card
	
	func testDosesCardStaticValues() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 7,
				keyFigures: [keyFigure(rank: .secondary), keyFigure(rank: .tertiary)]
			)
		)

		XCTAssertEqual(viewModel.illustrationImage, UIImage(named: "Doses"))
		XCTAssertEqual(viewModel.title, AppStrings.Statistics.Card.DoseRates.title)
		XCTAssertEqual(viewModel.subtitle, AppStrings.Statistics.Card.fromNationWide)
		XCTAssertEqual(viewModel.secondaryTitle, AppStrings.Statistics.Card.DoseRates.secondaryLabelTitle)
		XCTAssertEqual(viewModel.tertiaryTitle, AppStrings.Statistics.Card.DoseRates.tertiaryLabelTitle)
	}
	
	func testDosesCardPrimaryTitleToday() throws {
		let today = Date()

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 7,
				updatedAt: Int64(today.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Heute")
	}

	func testDosesCardPrimaryTitleYesterday() throws {
		let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()))

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 7,
				updatedAt: Int64(yesterday.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Gestern")
	}

	func testDosesCardPrimaryTitleOtherDate() throws {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 7,
				updatedAt: 1610891698, // 2021-01-17
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "17.01.2021")
	}

	// MARK: - Infections Card

	func testInfectionsCardStaticValues() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 1,
				keyFigures: [keyFigure(rank: .secondary), keyFigure(rank: .tertiary)]
			)
		)

		XCTAssertEqual(viewModel.title, AppStrings.Statistics.Card.Infections.title)
		XCTAssertEqual(viewModel.illustrationImage, UIImage(named: "Illu_Bestaetigte_Neuinfektionen"))
		XCTAssertEqual(viewModel.secondaryTitle, AppStrings.Statistics.Card.Infections.secondaryLabelTitle)
		XCTAssertEqual(viewModel.tertiaryTitle, AppStrings.Statistics.Card.Infections.tertiaryLabelTitle)
	}

	
	func testInfectionsCardPrimaryTitleToday() throws {
		let today = Date()

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 1,
				updatedAt: Int64(today.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Heute")
	}

	func testInfectionsCardPrimaryTitleYesterday() throws {
		let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()))

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 1,
				updatedAt: Int64(yesterday.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Gestern")
	}

	func testInfectionsCardPrimaryTitleOtherDate() throws {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 1,
				updatedAt: 1610891698, // 2021-01-17
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "17.01.2021")
	}

	// MARK: - Incedences Card

	func testIncidenceCardStaticValues() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 2,
				keyFigures: []
			)
		)

		XCTAssertEqual(viewModel.title, AppStrings.Statistics.Card.Incidence.title)
		XCTAssertEqual(viewModel.illustrationImage, UIImage(named: "Illu_7-Tage-Inzidenz"))
		XCTAssertEqual(viewModel.primarySubtitle, AppStrings.Statistics.Card.Incidence.secondaryLabelTitle)
	}

	func testIncidenceCardPrimaryTitleToday() throws {
		let today = Date()

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 2,
				updatedAt: Int64(today.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis heute")
	}

	func testIncidenceCardPrimaryTitleYesterday() throws {
		let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()))

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 2,
				updatedAt: Int64(yesterday.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis gestern")
	}

	func testIncidenceCardPrimaryTitleOtherDate() throws {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 2,
				updatedAt: 1610891698, // 2021-01-17
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis 17.01.2021")
	}

	// MARK: - KeySubmission Card

	func testKeySubmissionsCardStaticValues() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 3,
				keyFigures: [keyFigure(rank: .secondary), keyFigure(rank: .tertiary)]
			)
		)

		XCTAssertEqual(viewModel.title, AppStrings.Statistics.Card.KeySubmissions.title)
		XCTAssertEqual(viewModel.illustrationImage, UIImage(named: "Illu_Warnende_Personen"))
		XCTAssertEqual(viewModel.secondaryTitle, AppStrings.Statistics.Card.KeySubmissions.secondaryLabelTitle)
		XCTAssertEqual(viewModel.tertiaryTitle, AppStrings.Statistics.Card.KeySubmissions.tertiaryLabelTitle)
	}

	func testKeySubmissionsCardPrimaryTitleToday() throws {
		let today = Date()

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 3,
				updatedAt: Int64(today.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Heute")
	}

	func testKeySubmissionsCardPrimaryTitleYesterday() throws {
		let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()))

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 3,
				updatedAt: Int64(yesterday.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Gestern")
	}

	func testKeySubmissionsCardPrimaryTitleOtherDate() throws {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 3,
				updatedAt: 1610891698, // 2021-01-17
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "17.01.2021")
	}

	// MARK: - Reproduction Numbers Card

	func testReproductionNumberCardStaticValues() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 4,
				keyFigures: []
			)
		)

		XCTAssertEqual(viewModel.title, AppStrings.Statistics.Card.ReproductionNumber.title)
		XCTAssertEqual(viewModel.illustrationImage, UIImage(named: "Illu_7-Tage-R-Wert"))
		XCTAssertEqual(viewModel.primarySubtitle, AppStrings.Statistics.Card.ReproductionNumber.secondaryLabelTitle)
	}

	func testReproductionNumberCardPrimaryTitleToday() throws {
		let today = Date()

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 4,
				updatedAt: Int64(today.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Aktuell")
	}

	func testReproductionNumberCardPrimaryTitleYesterday() throws {
		let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: DateComponents(day: -1), to: Date()))

		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 4,
				updatedAt: Int64(yesterday.timeIntervalSince1970),
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Gestern")
	}

	func testReproductionNumberCardPrimaryTitleOtherDate() throws {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 4,
				updatedAt: 1610891698, // 2021-01-17
				keyFigures: [
					keyFigure(
						rank: .primary
					)
				]
			)
		)

		XCTAssertEqual(viewModel.primaryTitle, "Bis 17.01.2021")
	}

	func testInfectionsCardPrimaryFigureNil() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 1,
				keyFigures: [keyFigure(rank: .secondary), keyFigure(rank: .tertiary)]
			)
		)

		XCTAssertNil(viewModel.primaryTitle)
		XCTAssertNil(viewModel.primaryValue)
		XCTAssertNil(viewModel.primaryTrendImage)
		XCTAssertNil(viewModel.primaryTrendImageTintColor)
		XCTAssertNil(viewModel.primaryTrendAccessibilityLabel)
		XCTAssertNil(viewModel.primaryTrendAccessibilityValue)
	}

	func testInfectionsCardSecondaryFigureNil() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 1,
				keyFigures: [keyFigure(rank: .primary), keyFigure(rank: .tertiary)]
			)
		)

		XCTAssertNil(viewModel.secondaryTitle)
		XCTAssertNil(viewModel.secondaryValue)
		XCTAssertNil(viewModel.secondaryTrendImage)
		XCTAssertNil(viewModel.secondaryTrendImageTintColor)
		XCTAssertNil(viewModel.secondaryTrendAccessibilityLabel)
		XCTAssertNil(viewModel.secondaryTrendAccessibilityValue)
	}

	func testInfectionsCardTertiaryFigureNil() {
		let viewModel = HomeStatisticsCardViewModel(
			for: keyFigureCard(
				cardID: 1,
				keyFigures: [keyFigure(rank: .primary), keyFigure(rank: .secondary)]
			)
		)

		XCTAssertNil(viewModel.tertiaryTitle)
		XCTAssertNil(viewModel.tertiaryValue)
	}

	// MARK: - Private

	private func keyFigureCard(
		cardID: Int32 = 0,
		updatedAt: Int64 = 0,
		keyFigures: [SAP_Internal_Stats_KeyFigure] = []
	) -> SAP_Internal_Stats_KeyFigureCard {
		var cardHeader = SAP_Internal_Stats_CardHeader()
		cardHeader.cardID = cardID
		cardHeader.updatedAt = updatedAt

		var card = SAP_Internal_Stats_KeyFigureCard()
		card.header = cardHeader
		card.keyFigures = keyFigures

		return card
	}

	private func keyFigure(
		rank: SAP_Internal_Stats_KeyFigure.Rank = .unspecifiedRank,
		value: Double = 0,
		decimals: Int32 = 0,
		trend: SAP_Internal_Stats_KeyFigure.Trend = .unspecifiedTrend,
		trendSemantic: SAP_Internal_Stats_KeyFigure.TrendSemantic = .unspecifiedTrendSemantic
	) -> SAP_Internal_Stats_KeyFigure {
		var keyFigure = SAP_Internal_Stats_KeyFigure()
		keyFigure.rank = rank
		keyFigure.value = value
		keyFigure.decimals = decimals
		keyFigure.trend = trend
		keyFigure.trendSemantic = trendSemantic

		return keyFigure
	}

	private func checkFormattedValue(
		value: Double = 0,
		decimals: Int32 = 0,
		expectedString: String,
		expectedStringWithPercent: String
	) {
		for id in HomeStatisticsCard.allCases.map({ $0.rawValue }) {
			for rank in [SAP_Internal_Stats_KeyFigure.Rank.primary, .secondary, .tertiary] {
				let viewModel = HomeStatisticsCardViewModel(
					for: keyFigureCard(
						cardID: id,
						keyFigures: [keyFigure(
							rank: rank,
							value: value,
							decimals: decimals
						)]
					)
				)

				switch rank {
				case .primary:
					switch HomeStatisticsCard(rawValue: id) {
					case .atLeastOneVaccinatedPerson, .fullyVaccinatedPeople:
						XCTAssertEqual(viewModel.primaryValue, expectedStringWithPercent)
					case .infections, .incidence, .keySubmissions, .reproductionNumber, .appliedVaccinationsDoseRates:
						XCTAssertEqual(viewModel.primaryValue, expectedString)
					case .none:
						XCTFail("Unrecognised Card type")
					}
				case .secondary:
					XCTAssertEqual(viewModel.secondaryValue, expectedString)
				case .tertiary:
					XCTAssertEqual(viewModel.tertiaryValue, expectedString)
				default:
					XCTFail("Only actual ranks are tested")
				}
			}
		}
	}

	private func checkTrendImageAndAccessibilityLabel(
		trend: SAP_Internal_Stats_KeyFigure.Trend,
		expectedImage: UIImage?,
		expectedAccessibilityLabel: String?
	) {
		for id in HomeStatisticsCard.allCases.map({ $0.rawValue }) {
			for rank in [SAP_Internal_Stats_KeyFigure.Rank.primary, .secondary] {
				let viewModel = HomeStatisticsCardViewModel(
					for: keyFigureCard(
						cardID: id,
						keyFigures: [keyFigure(
							rank: rank,
							trend: trend
						)]
					)
				)

				switch rank {
				case .primary:
					XCTAssertEqual(viewModel.primaryTrendImage, expectedImage)
					XCTAssertEqual(viewModel.primaryTrendAccessibilityLabel, expectedAccessibilityLabel)
				case .secondary:
					XCTAssertEqual(viewModel.secondaryTrendImage, expectedImage)
					XCTAssertEqual(viewModel.secondaryTrendAccessibilityLabel, expectedAccessibilityLabel)
				default:
					XCTFail("Only actual ranks are tested")
				}
			}
		}
	}

	private func checkTrendImageTintColorAndAccessibilityValue(
		trendSemantic: SAP_Internal_Stats_KeyFigure.TrendSemantic,
		expectedColor: UIColor?,
		expectedAccessibilityValue: String?
	) {
		for id in HomeStatisticsCard.allCases.map({ $0.rawValue }) {
			for rank in [SAP_Internal_Stats_KeyFigure.Rank.primary, .secondary] {
				let viewModel = HomeStatisticsCardViewModel(
					for: keyFigureCard(
						cardID: id,
						keyFigures: [keyFigure(
							rank: rank,
							trendSemantic: trendSemantic
						)]
					)
				)

				switch rank {
				case .primary:
					XCTAssertEqual(viewModel.primaryTrendImageTintColor?.cgColor, expectedColor?.cgColor)
					XCTAssertEqual(viewModel.primaryTrendAccessibilityValue, expectedAccessibilityValue)
				case .secondary:
					XCTAssertEqual(viewModel.secondaryTrendImageTintColor?.cgColor, expectedColor?.cgColor)
					XCTAssertEqual(viewModel.secondaryTrendAccessibilityValue, expectedAccessibilityValue)
				default:
					XCTFail("Only actual ranks are tested")
				}
			}
		}
	}

}
