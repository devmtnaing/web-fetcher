#!/usr/bin/env ruby

require "mechanize"
require "open-uri"
require "fileutils"
require "logger"

# Begin: Constant variables
FETCHED_SITES_DIR = "fetched_sites"
# End: Constant variables

# Begin: Helper methods
def convert_to_folder_name(url)
  uri = URI.parse(url)
  uri.host
end

def create_destinated_folder(folder_name)
  FileUtils.mkdir_p File.join(FETCHED_SITES_DIR, folder_name)
end
# End: Helper methods

# Begin: Main program
agent = Mechanize.new
agent.log = Logger.new "fetch.log"

ARGV.each_with_index do |url, index|
  begin 
    puts "Started fetching: #{url}"
    page = agent.get(url)
    destinated_folder = create_destinated_folder(convert_to_folder_name(url))

    File.open(File.join(destinated_folder, "index.html"), "w") do |file|
      file.write(page.content)
    end
    puts "Finished fetching: #{url}"
  rescue Exception => e
    puts "Failed to fetch: #{e.message}"
    agent.log.error(e.message)
    next
  end
  puts "\n" unless index == ARGV.length - 1
end
# End: Main program
