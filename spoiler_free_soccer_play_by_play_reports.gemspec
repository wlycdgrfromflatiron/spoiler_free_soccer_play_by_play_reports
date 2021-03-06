
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "spoiler_free_soccer_play_by_play_reports/version"

Gem::Specification.new do |spec|
  spec.name          = "spoiler_free_soccer_play_by_play_reports"
  spec.version       = SpoilerFreeSoccerPlayByPlayReports::VERSION
  spec.authors       = ["Ilya Zarembsky"]
  spec.email         = ["wlycdgrfromflatiron@gmail.com"]

  spec.summary       = %q{A CLI for viewing spoiler-free play-by-play soccer match reports. Data from Sportsmole}
  spec.homepage      = "https://rubygems.org/gems/spoiler_free_soccer_play_by_play_reports"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.11.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_runtime_dependency "nokogiri", "~> 1.8"
end
