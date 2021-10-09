#!/usr/bin/ruby2.7 -w

require 'json'
require 'byebug'

module Theme
  JSON_DEST = "#{ENV['HOME']}/.config/awesome/current_user_theme.json"
  SAVE_DIR = "#{ENV['HOME']}/.config/awesome/user_themes"

  def get_current()
    if not File.file?(JSON_DEST)
      return {}
    else
      File.open(JSON_DEST) { |fh| return JSON.parse(fh.read) }
    end
  end

  def write(th_json)
    File.open(JSON_DEST, 'w') { |fh| fh.write(th_json) }
    apply(JSON.parse(th_json)['name'])
  end

  def save(th, th_json)
    not Dir.exists?(SAVE_DIR) and Dir.mkdir_p(SAVE_DIR)
    File.open(%Q(#{SAVE_DIR}/#{th['name']}.json), 'w') { |fh|
      fh.write(th_json)
    }
  end

  def get_all()
    return Dir.children(SAVE_DIR).map { |c| SAVE_DIR + '/' + c }
  end

  def apply(query)
    get_json = ->(f) { File.open(f) { |fh| fh.read() } }

    themes = get_all()
    if not themes.empty?
      required = themes.grep(Regexp.new(query, 'i')).dig(0)
      if required
        write(get_json.call(required))
      else
        raise Exception.new("Search query failed")
      end
    else
      raise Exception.new("No themes have been created yet.")
    end
  end

  def apply_with_rofi()
    themes = get_all()
    if not themes.empty?
      themes_s = themes.map {|th| th.sub(Regexp.new('^' + SAVE_DIR + '/', 'i'), '')}.join('\n')
      choice = %x(echo '#{themes_s}' | rofi -dmenu).chomp
      apply(choice)
    end
  end
end
