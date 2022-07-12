//
// 🦠 Corona-Warn-App
//

import Foundation
import AnyCodable
import JsonLogic

enum ParameterType {
	static let number = "number"
	static let string = "string"
	static let localDate = "localDate"
	static let localDateTime = "localDateTime"
	static let utcDate = "utcDate"
	static let utcDateTime = "utcDateTime"
}

enum UITextType {
	static let string = "string"
	static let plural = "plural"
	static let systemTimeDependent = "system-time-dependent"
}

struct DCCUITextParameter {
	let type: String
	let value: Any
}

public struct DCCUIText: Codable, Equatable {
	
	// MARK: - Internal
	
	let type: String?
	let quantity: Int?
	let quantityParameterIndex: Int?
	let functionName: String?
	let localizedText: [String: AnyCodable]?
	let parameters: AnyCodable

	static let inputDateFormatterWithFractionalSeconds: ISO8601DateFormatter = .iso8601DateFormatterWithFractionalSeconds()
	static let inputDateFormatterWithoutFractionalSeconds: ISO8601DateFormatter = ISO8601DateFormatter()
	static let localDateFormatter: DateFormatter = .localDateFormatter()
	static let localDateTimeFormatter: DateFormatter = .localDateTimeFormatter()
	static let outputDateFormatter: DateFormatter = .outputDateFormatter()
	static let outputDateTimeFormatter: DateFormatter = .outputDateTimeFormatter()

	func localized(languageCode: String? = Locale.current.languageCode, cclService: CCLServable) -> String {
		switch type {
		case UITextType.string:
			return localizedSingleFormattedText(languageCode: languageCode)
		case UITextType.plural:
			return localizedPluralFormattedText(languageCode: languageCode)
		case UITextType.systemTimeDependent:
			return localizedSystemTimeDependentFormattedText(languageCode: languageCode, service: cclService)
		default:
			return ""
		}
	}
	
	// MARK: - Private
	
	private func localizedSingleFormattedText(languageCode: String?) -> String {
		guard var formatText = localizedSingleTemplateText(languageCode: languageCode) else {
			return ""
		}
		
		// replacing %s with %@, %1$s with %1$@ and so on
		formatText = formatText.replacingOccurrences(of: "%(\\d\\$)?s", with: "%$1@", options: .regularExpression, range: nil)
		
		if let parameters = parameters.value as? [[String: Any]] {
			if parameters.isEmpty {
				// regular text without placeholders
				return formatText
			} else { // regular text with placeholder
				guard let formatParameters = mappedParameters(parameters: parameters) else {
					return ""
				}

				// text shall be determined by passing formatText and formatParameters to a printf-compatible format function
				return formattedTextWithParameters(formatText: formatText, parameters: formatParameters) ?? ""
			}
		} else {
			// regular text without placeholders
			return formatText
		}
	}
	
	private func localizedPluralFormattedText(languageCode: String?) -> String {
		guard let formatText = localizedPluralTemplateText(languageCode: languageCode) else {
			return ""
		}
		
		if let parameters = parameters.value as? [[String: Any]] {
			if parameters.isEmpty {
				// text without parameters
				if let textDescriptorQuantity = quantity {
					return quantityBasedFormatText(formatText: formatText, quantity: textDescriptorQuantity) ?? ""
				}
			} else {
				guard let formatParameters = mappedParameters(parameters: parameters) else {
					return ""
				}
				
				// quantity shall be set to the value of textDescriptor.quantity
				if let textDescriptorQuantity = quantity {
					guard let quantityBasedFormatText = quantityBasedFormatText(formatText: formatText, quantity: textDescriptorQuantity) else {
						return ""
					}
					// text shall be determined by passing formatTexts and formatParameters to a quantity-depending printf-compatible format function by using quantity
					return formattedTextWithParameters(formatText: quantityBasedFormatText, parameters: formatParameters) ?? ""
				} else if let parameterIndex = quantityParameterIndex {
					// Otherwise quantity shall be set to the element of formatParameters at the index described by textDescriptor.quantityParameterIndex.
					if let quantityValue = formatParameters[parameterIndex].value as? Int {
						// text shall be determined by passing formatTexts and formatParameters to a quantity-depending printf-compatible format function by using quantity
						return formattedTextWithParameters(formatText: quantityBasedFormatText(formatText: formatText, quantity: quantityValue) ?? "", parameters: formatParameters) ?? ""
					}
				}
			}
		}
		
		return ""
	}

	private func localizedSystemTimeDependentFormattedText(languageCode: String?, service: CCLServable) -> String {
		guard let parameters = parameters.value as? [String: Any], let functionName = functionName else {
			return ""
		}

		let anyDecodableParameters = parameters.reduce(into: [String: AnyDecodable]()) {
			$0[$1.key] = AnyDecodable($1.value)
		}
		
		do {
			// newTextDescriptor shall be determined by calling Calling a CCL API with JsonFunctions.
			let newDCCUIText: DCCUIText = try service.evaluateFunctionWithDefaultValues(
				name: functionName,
				parameters: anyDecodableParameters
			)
			return newDCCUIText.localized(languageCode: languageCode, cclService: service)
		} catch {
			Log.error("Unable to create newTextDescriptor - DCCUIText", error: error)
			return ""
		}
	}

	private func localizedSingleTemplateText(languageCode: String?) -> String? {
		// use language code, if there is no property for the language code, en shall be used
		if let localizedFormatText = localizedText?[languageCode ?? "en"]?.value as? String {
			return localizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["en"]?.value as? String { // if language code is available, localized text is not there, en shall be used
			return fallbackLocalizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["de"]?.value as? String { // if en is not available, de shall be used
			return fallbackLocalizedFormatText
		} else {
			return nil
		}
	}
	
	private func localizedPluralTemplateText(languageCode: String?) -> [String: String]? {
		// use language code, if there is no property for the language code, en shall be used
		if let localizedFormatText = localizedText?[languageCode ?? "en"]?.value as? [String: String] {
			return localizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["en"]?.value as? [String: String] { // if language code is available, localized text is not there, en shall be used
			return fallbackLocalizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["de"]?.value as? [String: String] { // if en is not available, de shall be used
			return fallbackLocalizedFormatText
		} else {
			return nil
		}
	}
	
	private func mappedParameters(parameters: [[String: Any]]) -> [DCCUITextParameter]? {
		var mappedParameters: [DCCUITextParameter] = []
		
		// we could get multiple parameters
		for parameter in parameters {
			guard let type = parameter["type"] as? String, let value = parameter["value"] else {
				return nil
			}
			mappedParameters.append(DCCUITextParameter(type: type, value: value))
		}
		return mappedParameters
	}

	private func formattedTextWithParameters(formatText: String, parameters: [DCCUITextParameter]) -> String? {
		let parsedParameters = parameters.compactMap { parseFormatParameter(parameter: $0) }
		
		// ensuring if all parameters are parsed
		if parsedParameters.count != parameters.count {
			return nil
		}
		return String(format: formatText, arguments: parsedParameters)
	}
	
	private func quantityBasedFormatText(formatText: [String: String], quantity: Int) -> String? {
		// work around for stringsdict, returns key for formatText
		let keyFormatText = String(format: NSLocalizedString("DCC_UIText_plural", tableName: "DCCUIText", comment: ""), quantity)
		let quantitySpecificFormatText = formatText[keyFormatText]
		// replacing %s with %@, %1$s with %1$@ and so on
		return quantitySpecificFormatText?.replacingOccurrences(of: "%(\\d\\$)?s", with: "%$1@", options: .regularExpression, range: nil)
	}
	
	private func formattedDate(value: Any, dateType: String) -> String? {
		guard let stringDate = value as? String, let formattedDate = date(from: stringDate) else {
			return nil
		}
			
		// only date related types will be handled here
		switch dateType {
		case ParameterType.localDate:
			return DCCUIText.localDateFormatter.string(from: formattedDate)
		case ParameterType.localDateTime:
			return DCCUIText.localDateTimeFormatter.string(from: formattedDate)
		case ParameterType.utcDate:
			return DCCUIText.outputDateFormatter.string(from: formattedDate)
		case ParameterType.utcDateTime:
			return DCCUIText.outputDateTimeFormatter.string(from: formattedDate)
		default:
			return nil
		}
	}

	private func date(from string: String) -> Date? {
		DCCUIText.inputDateFormatterWithFractionalSeconds.date(from: string) ?? DCCUIText.inputDateFormatterWithoutFractionalSeconds.date(from: string)
	}

	private func parseFormatParameter(parameter: DCCUITextParameter) -> CVarArg? {
		switch parameter.type {
		case ParameterType.number:
			// entry.value shall be treated as a numeric value
			return parameter.value as? Int ?? parameter.value as? Double
		case ParameterType.localDate:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (without time information) in local time zone
			return formattedDate(value: parameter.value, dateType: ParameterType.localDate)
		case ParameterType.localDateTime:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (with time information) in local time zone
			return formattedDate(value: parameter.value, dateType: ParameterType.localDateTime)
		case ParameterType.utcDate:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (without time information) in UTC
			return formattedDate(value: parameter.value, dateType: ParameterType.utcDate)
		case ParameterType.utcDateTime:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (with time information) in UTC
			return formattedDate(value: parameter.value, dateType: ParameterType.utcDateTime)
		default:
			// otherwise, entry.value shall be treated as a string
			return parameter.value as? String
		}
	}
}

private extension ISO8601DateFormatter {
	class func iso8601DateFormatterWithFractionalSeconds() -> ISO8601DateFormatter {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}
}

private extension DateFormatter {
	class func outputDateFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		formatter.timeZone = .utcTimeZone
		return formatter
	}
	
	class func outputDateTimeFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		formatter.timeZone = .utcTimeZone
		return formatter
	}

	class func localDateFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		return formatter
	}
	
	class func localDateTimeFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}
}
