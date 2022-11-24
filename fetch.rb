#!/usr/bin/env ruby

require "mechanize"
require "open-uri"
require "fileutils"

agent = Mechanize.new

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

ARGV.each do |url|
  begin 
    page = agent.get(url)
    destinated_folder = create_destinated_folder(convert_to_folder_name(url))

    File.open(File.join(destinated_folder, "index.html"), "w") do |file|
      file.write(page.content)
    end
  rescue Exception => e
    puts e.message
    next
  end
end