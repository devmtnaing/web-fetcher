This is just simple little ruby script to fetch and download web content of given urls

# Getting started

## How to run locally

```ruby
ruby fetch.rb http://google.com http://youtube.com
```

## Limitations

- Downloaded content fail to load some of the assets (especially images). Therefore, local html file will not be loaded properly.
- Not able to properly fetch react/angular powered web pages.
- Not able to properly fetch web pages that have to trigger javascript to fully load its content. A bit different from react/angular web apps

## Interesting

- While fetching [medium](https://medium.com), its web content are properly downloaded locally. However, accessing the downloaded html would only render **404 out of nothing, something** content. Domain name issue?
