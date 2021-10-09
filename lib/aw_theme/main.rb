# lib/main.rb

require_relative 'cmd'
require_relative 'write_theme'

include Theme

def main()
  theme_template = Theme::get_current()
  options = Commandline.main(theme_template)
  options.has_key? "inject_lua" and %x(bash ./inject_lua.sh)

  # Apply args
  if options.has_key? "apply"
    Theme::apply(options["apply"])
  elsif options.has_key? "apply_with_rofi"
    Theme::apply_with_rofi()
  else
    if not options.has_key? 'name'
      raise Exception.new('No name provided for the new theme')
    end
    Theme::save(options, JSON.dump(options))
    Theme::apply(options['name'])
  end
end
