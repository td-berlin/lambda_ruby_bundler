# LambdaRubyBundler

LambdaRubyBundler is a command line tool for packaging Ruby applications for AWS Lambda.

Most notably, it properly compiles dependencies with C extensions, using custom Docker image based on [lambci/lambda:build-ruby2.5](https://hub.docker.com/r/lambci/lambda/tags).

## Installation

Add this line to your application's Gemfile for programmatic usage:

```ruby
gem 'lambda_ruby_bundler'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lambda_ruby_bundler

## Usage

Note that the library requires running Docker on your system!

Let's assume following directory structure:

```
/tmp/my_serverless_app
├── Gemfile
├── Gemfile.lock
├── backend/
│   └── handler.rb
└── node_modules/...
```

### Command line usage

Run:

```bash
lambda_ruby_bundler \
  --root-path /tmp/my_serverless_app \
  --app-path backend \
  --out /tmp/build.zip
```

It will produce a ZIP file with following files:

```
├ handler.rb
├ vendor/bundle/...
```

Note that:

1. Structure will be "flattened" (based on contents of the `--app-path`)
2. Only gems **not in** development and test groups will be bundled
3. The first run might be very long. It requires pulling the base image, building Bundler image, fetching and building gems for your application

### Programmatic usage

```ruby
executor = LambdaRubyBundler::Executor.new(
  '/tmp/my_serverless_app',
  'backend'
)

File.write('bundle.zip', executor.run.read)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/td-berlin/lambda_ruby_bundler. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LambdaRubyBundler project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](CODE_OF_CONDUCT.md).
