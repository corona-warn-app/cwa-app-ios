source "https://rubygems.org"

if RUBY_VERSION =~ /2.7/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem "fastlane"
gem "xcov"
gem "xcode-install"
gem "jazzy"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
