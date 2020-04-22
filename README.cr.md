# slack.cr

slack for [Crystal](http://crystal-lang.org/).

- crystal: 0.34.0

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  slack:
    github: maiha/slack
```

2. Run `shards install`

## Usage

```crystal
require "slack"
```

## Development

### catalog

Bundled catalog can be generated as follows.

```console
$ make gen

# update data
$ rm -rf gen
$ make gen
```

## Contributing

1. Fork it (<https://github.com/maiha/slack.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) - creator and maintainer
