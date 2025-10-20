# frozen_string_literal: true

require_relative "lib/dialog_lk_esms/version"

Gem::Specification.new do |spec|
  spec.name = "dialog_lk_esms"
  spec.version = DialogLkEsms::VERSION
  spec.authors = ["Lahiru Himesh Madusanka"]
  spec.email = ["lahiru.lahirumadusanka@gmail.com"]

  spec.summary = "Dry‑rb compatible client for Dialog eSMS (URL API)"
  spec.description = "Dry‑rb compatible client for Dialog eSMS (URL API)"
  spec.homepage = "https://github.com/sdglhm/dialog_lk_esms"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Allow pushing to RubyGems.org
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sdglhm/dialog_lk_esms"
  spec.metadata["changelog_uri"] = "https://github.com/sdglhm/dialog_lk_esms/blob/main/CHANGELOG.md"

  spec.add_dependency "dry-configurable", "~> 1.0"
  spec.add_dependency "dry-types", "~> 1.0"
  spec.add_dependency "dry-monads", "~> 1.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)}) || f.end_with?('.gem')
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
