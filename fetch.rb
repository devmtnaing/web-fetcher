#!/usr/bin/env ruby

require "fileutils"
require "json"
require "logger"
require "mechanize"
require "nokogiri"
require "open-uri"

# Begin: Constant variables
FETCHED_SITES_DIR = "fetched_sites"
IMAGES_DIR = "images"
METADATA_FILE = File.join(FETCHED_SITES_DIR, "metadata.json")
# End: Constant variables

# Begin: Helper methods
def format_asset_name(asset_name)
  # Kinda a Hack since asset value like `name.png?query=value..` does not seem to be linked properly 
  # within downloaded local html content.
  asset_name.split("?")[0]
end

def convert_to_folder_name(url)
  uri = URI.parse(url)

  # To ensure we could download different path of the same domain in different folders
  "#{uri.host.gsub(/^www\./, "")}#{uri.path}#{uri.query}"
end

def create_destinated_folder(folder_name)
  FileUtils.mkdir_p File.join(FETCHED_SITES_DIR, folder_name)
end

def fetch_content(url)
  page = @agent.get(url)
  Nokogiri::HTML(page.content) # Easier to manipulate the content with Nokogiri
end

def parse_last_fetch_time(time)
  return "NA" unless time

  Time.parse(time).strftime("%a %b %d %Y %H:%M %Z")
end

def print_metadata(key)
  puts <<-METADATA_MESSAGE
    Metadata
    --------------------------------
    site: #{key}
    num_links: #{retrieve_existing_metadata[key]["num_links"]}
    images: #{retrieve_existing_metadata[key]["images"]}
    last_fetch: #{parse_last_fetch_time(retrieve_existing_metadata[key]["last_fetch"])}
  METADATA_MESSAGE
end

def retrieve_existing_metadata
  return {} unless File.exist?(METADATA_FILE)

  JSON.parse(File.read(METADATA_FILE))
end

def save_and_localize_assets(folder_name, content)
  puts "Saving assets to local folder."
  save_and_localize_images(folder_name, content.xpath("//img[@src]"))
end

def save_and_localize_images(folder_name, images)
  image_dir = create_destinated_folder(File.join(folder_name, IMAGES_DIR))

  images.each do |image|
    # Not able to handle base64 images
    next if image["src"].empty? || image["src"].include?("data:image")

    formatted_image_name = format_asset_name(File.basename(image["src"]))
    puts formatted_image_name
    File.open(File.join(image_dir, formatted_image_name), "w") do |file|
      image_url = if URI.parse(image["src"]).host
                    image["src"]
                  else
                    image["src"].prepend(folder_name).prepend("http://www.")
                  end
      begin
        sleep(rand/100) # Multiple images then we would constantly be sending many requests to download assets
        file.write(URI.open(image_url).read)

        # Modify the local html content
        image["src"] = "./#{IMAGES_DIR}/#{formatted_image_name}"
      rescue Exception => e
        puts "Warning: #{e.message}"
        next
      end
    end
  end
end

def save_html_content(folder_name, content)
  puts "Saving html content to local folder"

  content_dir = create_destinated_folder(folder_name)
  File.open(File.join(content_dir, "index.html"), "w") do |file|
    file.write(content)
  end
end

def save_metadata(key, content)
  puts "Saving content metadata"
  existing_metadata = retrieve_existing_metadata
  existing_metadata[key] = { 
    "num_links": content.xpath("//a[@href]").length,
    "images": content.xpath("//img[@src]").length,
    "last_fetch": Time.now.utc
  }
  File.open(METADATA_FILE, "w") do |file|
    file.write(JSON.pretty_generate(existing_metadata))
  end
end
# End: Helper methods

# Begin: Main program
@agent = Mechanize.new
@agent.log = Logger.new "fetch.log"
urls = ARGV.reject { |arg| arg =~ /--[a-z]/}
metadata_arg = ARGV.include?("--metadata")
save_assets_arg = ARGV.include?("--save-assets")

urls.each_with_index do |url, index|
  begin 
    puts "Started fetching: #{url}"

    content = fetch_content(url)
    folder_name = convert_to_folder_name(url)

    save_and_localize_assets(folder_name, content) if save_assets_arg
    save_html_content(folder_name, content)
    if metadata_arg
      save_metadata(folder_name, content)
      print_metadata(folder_name)
    end

    puts "Finished fetching: #{url}"
  rescue Exception => e
    puts "Failed to fetch: #{e.message}"
    @agent.log.error(e.message)
    next
  end
  puts "\n" unless index == urls.length - 1
end
# End: Main program
