#!/usr/bin/env ruby

require "mechanize"
require "open-uri"

agent = Mechanize.new

# Begin: Helper methods
def format_file_name(url)
  uri = URI.parse(url)
  uri.host
end
# End: Helper methods

ARGV.each do |url|
  begin 
    page = agent.get(url)
    File.open(format_file_name(url).concat(".html"), "w") do |file|
      file.write(page.content)
    end
  rescue Exception => e
    puts e.message
    next
  end
end