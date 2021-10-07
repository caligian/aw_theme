# AwTheme

This gem allows you to theme Awesome WM. Anything that can be JSONized can be used for theming. However, be wary of numeric values.  
In extras/, you will find a basic template which you can examine and further amend this gem yourself as and when required. I strongly suggest you to modify lib/cmd.rb if the current ones are limiting. 

## Usage
These are the commandline parameters. For convenience, I am dividing it into sections

#### Hex colors
--fg-normal    #HEX      
--bg-normal    #HEX
--fg-focus     #HEX
--bg-focus     #HEX
--border-focus #HEX
Normal and focus colors. You can add your own here by editing cmd.rb directly

#### Paths
--wallpaper PATH
Define a path to a valid wallpaper here. 

#### Other
--tasklist-align STR 
Title alignment

#### Theming
--name STR
Mandatory while saving the theme while using the above params

--apply REGEX
--apply-with-rofi
The former applies theme by taking in a Regexp query and the latter uses rofi for selection

#### Misc
--inject-lua PATH
A certain code segment needs to be added. 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aw_theme'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install aw_theme

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/aw_theme.
