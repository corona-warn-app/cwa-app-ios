module Fastlane
  module Actions
    class UpdateThirdPartyNoticeAction < Action
      def self.run(params)
        require 'json'
        require 'open-uri'
        
        # Dir.pwd should result in '/src/xcode' of the project.
        unless Dir.pwd.end_with?("/src/xcode")
          UI.user_error!("Please ensure that you execute fastlane in the /src/xcode folder.")
        end

        # Find the licenses.json that contains the information.
        licenses_file_path = File.expand_path("../../licenses.json", Dir.pwd)

        # Build the path for the to be updated license file.
        third_party_notices_path = File.expand_path("../../THIRD-PARTY-NOTICES", Dir.pwd)

        # Find the path to file that contains the swift model.
        swift_model_file_path = Dir.glob("#{Dir.pwd}/**/AppInformationViewController+LegalModel.swift")[0]

        # Read the json that is in the following form:
        # 
        #    [{
        #        "component": "...",
        #        "licensor": "...",
        #        "website": "...",
        #        "license": "...",
        #        "licenseUrl": "..."
        #    }]
        #
        json_content = File.read(licenses_file_path)
        licenses = JSON.parse(json_content)

        full_licenses = {}

        content = THIRD_PARTY_NOTICE_HEADER
        
        full_licenses_texts = ""

        licenses.each do |license_info|
          component = license_info['component']
          licensor = license_info['licensor']
          website = license_info['website']
          license = license_info['license']
          license_url = license_info['licenseUrl']

          unless component
            UI.user_error!("Missing \"component\" in license.")
          end
          
          unless licensor
            UI.user_error!("Missing \"licensor\" in license for #{component}.")
          end

          unless website
            UI.user_error!("Missing \"website\" in license for #{component}.")
          end

          unless license
            UI.user_error!("Missing \"license\" in license for #{component}.")
          end

          unless license_url
            UI.user_error!("Missing \"licenseUrl\" in license for #{component}.")
          end
          
          content += "Component: #{component}\n"
          content += "Licensor:  #{licensor}\n"
          content += "Website:   #{website}\n"
          content += "License:   #{license}\n\n"

          begin
            license_text = open(license_url) { |f| f.read }

            # When the license is an Apache License cut off the APPENDIX section.
            if license_text["Apache License"]
              license_text = license_text[0, license_text.index("END OF TERMS AND CONDITIONS")]
            end

            # Strip trailing whitespace
            license_text.rstrip!

            # Store the full text so it can be reused when writing the swift file.
            full_licenses[component] = license_text

            full_licenses_texts += license_text
            full_licenses_texts += "\n"
            full_licenses_texts += SEPARATOR
          rescue
            UI.user_error!("Could not download the full license for #{license['component']}")
          end
        end
        
        content += SEPARATOR
        content += full_licenses_texts

        # Update the THIRD-PARTY-NOTICES file with the new content.
        File.open(third_party_notices_path, "w") {|file| file.puts content }

        # Update the swift file.
        swift_content = File.read(swift_model_file_path)
        swift_content = swift_content[0, swift_content.index(SWIFT_LEGAL_CELLS_DEFINITION) + SWIFT_LEGAL_CELLS_DEFINITION.length]
        swift_content += "\n"

        licenses.each_with_index do |license_info, index|
          component = license_info['component']
          licensor = license_info['licensor']

          license_text = full_licenses[component].lines.map(&:strip).join("\n")
          license_text.gsub!(/(.+)(?:\n)(\w+)/, '\1 \2')
          
          swift_content += "\t\t.legal("
          swift_content += "title: \"#{component}\", "
          swift_content += "licensor: \"#{licensor}\", "
          swift_content += "fullLicense: \"\"\"\n#{license_text}\n\"\"\")"
          swift_content += "#{index < licenses.size - 1 ? "," : ""}\n"
        end

        swift_content += "\t]\n}\n// swiftlint:enable line_length"

        File.open(swift_model_file_path, "w") {|file| file.puts swift_content }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Updates the license info in THIRD-PARTY-NOTICES and AppInformationViewController+LegalModel.swift"
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end

SEPARATOR = "#{"-" * 80}\n"

THIRD_PARTY_NOTICE_HEADER = 
%{ThirdPartyNotices
-----------------
corona-warn-app/cwa-app-ios uses third-party software or other resources that
may be distributed under licenses different from corona-warn-app/cwa-app-ios
software.
In the event that we overlooked to list a required notice, please bring this
to our attention by contacting us via this email:
corona-warn-app.opensource@sap.com


Components:
-----------
}

SWIFT_LEGAL_CELLS_DEFINITION = "private static let legalCells: [DynamicCell] = ["
