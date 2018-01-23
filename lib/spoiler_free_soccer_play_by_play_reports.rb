require "spoiler_free_soccer_play_by_play_reports/version"
require "spoiler_free_soccer_play_by_play_reports/formatter" # custom string formatting
require "spoiler_free_soccer_play_by_play_reports/printer" # console output
require "spoiler_free_soccer_play_by_play_reports/cli" # command-line interface logic
require "spoiler_free_soccer_play_by_play_reports/scrape" # domain-specific data retrieval and parsing
require "spoiler_free_soccer_play_by_play_reports/report" # data model, populated by scraper
require "nokogiri" # HTML parsing support library
require "open-uri" # HTML retrieval support library
require "io/console" # unbuffered input handling

require "pry" if WLY_DEBUG # interactive debugging
