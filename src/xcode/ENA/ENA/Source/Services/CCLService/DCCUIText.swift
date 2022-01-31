//
// 🦠 Corona-Warn-App
//

import Foundation
import AudioToolbox
import AnyCodable
import jsonlogic

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
	let type: String
	let quantity: Int?
	let quantityParameterIndex: Int?
	let functionName: String?
	let localizedText: [String: AnyCodable]?
	let parameters: AnyCodable

	static let dateFormatter: ISO8601DateFormatter = .iso8601DateFormatter()
	static let outputDateFormatter: DateFormatter = .outputDateFormatter()
	static let outputDateTimeFormatter: DateFormatter = .outputDateTimeFormatter()
	
	// MARK: - Internal

	func localized(languageCode: String? = Locale.current.languageCode) -> String? {
		switch type {
		case UITextType.string:
			return localizedSingleFormatText(languageCode: languageCode)
		case UITextType.plural:
			return localizedPluralFormatText(languageCode: languageCode)
		case UITextType.systemTimeDependent:
			return localizedSystemTimeDependentFormatText(languageCode: languageCode)
		default:
			return nil
		}
	}
	
	// MARK: - Private
	
	private func localizedSingleFormatText(languageCode: String?) -> String? {
		var formatText = ""
		
		// use language code, if there is no property for the language code, en shall be used
		if let localizedFormatText = localizedText?[languageCode ?? "en"]?.value as? String {
			formatText = localizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["de"]?.value as? String { // if en is not available, de shall be used
			formatText = fallbackLocalizedFormatText
		} else {
			return nil
		}
		
		// replacing %s with %@, %1$s with %1$@ and so on
		formatText = formatText.replacingOccurrences(of: "%(\\d\\$)?s", with: "%$1@", options: .regularExpression, range: nil)
		
		if let parameters = parameters.value as? [[String: Any]] {
			if parameters.isEmpty {
				// regular text without placeholders
				return formatText
			} else { // regular text with placeholder
				var mappedParameters: [DCCUITextParameter] = []
				
				// we could get multiple parameters
				for parameter in parameters {
					guard let type = parameter["type"] as? String, let value = parameter["value"] else {
						return nil
					}
					mappedParameters.append(DCCUITextParameter(type: type, value: value))
				}
				// text shall be determined by passing formatText and formatParameters to a printf-compatible format function
				return formattedTextWithParameters(formatText: formatText, parameters: mappedParameters)
			}
		} else {
			// regular text without placeholders
			return formatText
		}
	}
	
	private func localizedPluralFormatText(languageCode: String?) -> String? {
		guard let formatText = localizedFormatText(languageCode: languageCode) else {
			return nil
		}
		
		if let parameters = parameters.value as? [[String: Any]] {
			if parameters.isEmpty {
				// text without parameters
				if let textDescriptorQuantity = quantity {
					return quantityBasedFormatText(formatText: formatText, quantity: textDescriptorQuantity)
				}
			} else {
				var mappedParameters: [DCCUITextParameter] = []
				
				// we could get multiple parameters
				for parameter in parameters {
					guard let type = parameter["type"] as? String, let value = parameter["value"] else {
						return nil
					}
					mappedParameters.append(DCCUITextParameter(type: type, value: value))
				}
				
				// quantity shall be set to the value of textDescriptor.quantity
				if let textDescriptorQuantity = quantity {
					// text shall be determined by passing formatTexts and formatParameters to a quantity-depending printf-compatible format function by using quantity
					guard let quantityBasedFormatText = quantityBasedFormatText(formatText: formatText, quantity: textDescriptorQuantity) else {
						return nil
					}
					return formattedTextWithParameters(formatText: quantityBasedFormatText, parameters: mappedParameters)
				} else if let parameterIndex = quantityParameterIndex {
					// Otherwise quantity shall be set to the element of formatParameters at the index described by textDescriptor.quantityParameterIndex.
					if let quantityValue = mappedParameters[parameterIndex].value as? Int {
						// text shall be determined by passing formatTexts and formatParameters to a quantity-depending printf-compatible format function by using quantity
						return formattedTextWithParameters(formatText: quantityBasedFormatText(formatText: formatText, quantity: quantityValue) ?? "", parameters: mappedParameters)
					}
				}
			}
		}
		
		return nil
	}

	private func localizedSystemTimeDependentFormatText(languageCode: String?) -> String? {
		let service = CCLService()
		guard let parameters = parameters.value as? [String: AnyDecodable], let functionName = functionName else {
			return nil
		}
		
		do {
			// newTextDescriptor shall be determined by calling Calling a CCL API with JsonFunctions.
			let newDCCUIText: DCCUIText = try service.evaluateFunction(name: functionName, parameters: parameters)
			return newDCCUIText.localized(languageCode: languageCode)
		} catch {
			Log.error("Unable to create newTextDescriptor - DCCUIText", error: error)
			return nil
		}
	}

	private func localizedFormatText(languageCode: String?) -> [String: String]? {
		// use language code, if there is no property for the language code, en shall be used
		if let localizedFormatText = localizedText?[languageCode ?? "en"]?.value as? [String: String] {
			return localizedFormatText
		} else if let fallbackLocalizedFormatText = localizedText?["de"]?.value as? [String: String] {
			// if en is not available, de shall be used
			return fallbackLocalizedFormatText
		} else {
			return nil
		}
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
	
	private func parseDate(value: Any, dateType: String) -> String? {
		if let stringDate = value as? String {
			guard let formattedDate = DCCUIText.dateFormatter.date(from: stringDate) else {
				return nil
			}
			
			switch dateType {
			case ParameterType.localDate:
				return DateFormatter.localizedString(from: formattedDate, dateStyle: .short, timeStyle: .none)
			case ParameterType.localDateTime:
				return DateFormatter.localizedString(from: formattedDate, dateStyle: .short, timeStyle: .short)
			case ParameterType.utcDate:
				return DCCUIText.outputDateFormatter.string(from: formattedDate)
			case ParameterType.utcDateTime:
				return DCCUIText.outputDateTimeFormatter.string(from: formattedDate)
			default:
				return nil
			}
		} else {
			return nil
		}
	}

	private func parseFormatParameter(parameter: DCCUITextParameter) -> CVarArg? {
		switch parameter.type {
		case ParameterType.number:
			// entry.value shall be treated as a numeric value
			return parameter.value as? Int ?? parameter.value as? Double
		case ParameterType.localDate:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (without time information) in local time zone
			return parseDate(value: parameter.value, dateType: ParameterType.localDate)
		case ParameterType.localDateTime:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (with time information) in local time zone
			return parseDate(value: parameter.value, dateType: ParameterType.localDateTime)
		case ParameterType.utcDate:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (without time information) in UTC
			return parseDate(value: parameter.value, dateType: ParameterType.utcDate)
		case ParameterType.utcDateTime:
			// entry.value shall be treated as a ISO 8106 date string and formatted as date (with time information) in UTC
			return parseDate(value: parameter.value, dateType: ParameterType.utcDateTime)
		default:
			// otherwise, entry.value shall be treated as a string
			return parameter.value as? String
		}
	}
}

private extension ISO8601DateFormatter {
	class func iso8601DateFormatter() -> ISO8601DateFormatter {
		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return formatter
	}
}

private extension DateFormatter {
	class func outputDateTimeFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		formatter.timeZone = .utcTimeZone
		return formatter
	}
	
	class func outputDateFormatter() -> DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .none
		formatter.timeZone = .utcTimeZone
		return formatter
	}
}
