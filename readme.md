This is just simple little ruby script to fetch and download web content of given urls

# Getting started

## Usage

Basic command to fetch and download urls.

```ruby
ruby fetch.rb http://google.com http://youtube.com
```

### metadata tag

Use `--metadata` to record and display _number of links, images, and last fetched time_.

```ruby
ruby fetch.rb http://google.com --metadata
```

### save-assets tag

Use `--save-assets` to download assets (image, js, and css) to local folder.
The downloaded html content will reference the assets from the local folder.

```ruby
ruby fetch.rb http://google.com --save-assets
```

## Running the script

### How to run on local machine

Install required gems

```ruby
bundle install
```

Reference [Usage](#Usage) section for available commands

```ruby
# Example
ruby fetch.rb http://google.com http://youtube.com
```

Make it an executable file

```ruby
chmod +x fetch.rb

# Example
./fetch.rb http://google.com --metadata --save-assets
```

### How to run on Docker

Build a docker image

```ruby
docker build -t image_name .
```

Reference [Usage](#Usage) section for available commands

```ruby
docker run image_name http://google.com http://youtube.com
```

To check the downloaded content, `sh` into docker image.

```ruby
docker run --it --entrypoint sh image_name

# fetch.rb is already excutable
# Example command inside image
./fetch.rb http://google.com --metadata --save-assets
```

# Future development

## Limitations

- Not able to properly fetch react/angular powered web pages.
- Not able to properly fetch web pages that have to trigger javascript to fully load its content. A bit different from react/angular web apps
- --save-assets do not download base64 images
- `picture` html tag are not properly rendered in downloaded html content despite images are already been downloaded.
- image tags with `data-src` but without `src` are not able to be downloaded.

## Interesting

- While fetching [medium](https://medium.com), its web content are properly downloaded locally. However, accessing the downloaded html would only render **404 out of nothing, something** content. Domain name issue?

## Todo

- Refactor the code into modules and classes with tests
- Enable [Limitations](#Limitations)
- Much improvment to be done around downloading assets workflow and refactor (DRY)
