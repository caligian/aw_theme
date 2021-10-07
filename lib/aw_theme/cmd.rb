# lib/cmd.rb

require 'optparse'
require 'solid_assert'; SolidAssert.enable_assertions

module Extras
  class Misc
    class << self
      def valid_hex?(str)
        assert str =~ /^#[a-fA-F0-9]/, "Invalid hex: #{str}"
        str
      end
    end
  end

  class Params
    class << self
      def filter(args, &predicate)
        args = [args] if not args.is_a?(Array)
        args.select { |a| predicate.call(a) }
        args
      end

      def assert_true(args, &predicate)
        args = [args] if not args.is_a?(Array)
        args.map { |a| assert predicate.call(a) }
        args
      end

      def split_args(args, sep='::', ignore_whitespace=false)
        return args.split(/\s*#{sep}\s*/) if ignore_whitespace
        return args.split(/#{sep}/)
      end
    end
  end

  class PathOps
    class << self
      def valid_paths?(paths)
        paths.is_a? String and paths = [paths]
        paths.map { |p| assert File.exists?(p), "Invalid path: #{p}" }
        paths
      end

      def get_realpaths(paths)
        paths.is_a? String and paths = [paths]
        valid_paths?(paths)
        {}.update *paths.map { |p| {p => {realpath: File.realpath(p)}} }
      end

      def get_contents(paths, realpaths=false)
        paths.is_a? String and paths = [paths]
        _get_content = ->(path) { File.open(path) { |fh| fh.read() }}
        if realpaths
          contents = get_realpaths(paths)
          {}.update *contents.values.map { |v| v[:content] = _get_content.call(v[:realpath]); v }
        else
          {}.update *paths.map { |p| {p => {contents: _get_content.call(p)}} }
        end
      end
    end
  end
end

class Commandline
  class << self
    def get_long_switch_name(a)
      a.select { |e| e.is_a?(String) and e =~ /^--/  }.dig(0).gsub(/^--/, '').gsub(/-/, '_').sub(/=.*/, '')
    end

    def add_arg(arg_list, parser, store_in)
      pred = arg_list.pop
      pred_args = pred[...-1]
      pred = pred.shift

      case pred
      when Proc
        parser.on(*arg_list) { |value| store_in[get_long_switch_name(arg_list)] = pred.call(value, *pred_args) }
      when :default
        parser.on(*arg_list) { |value| store_in[get_long_switch_name(arg_list)] = value }
      else
        raise Exception.new
      end
    end

    def add_args(args_list, parser, store_in)
      args_list.map { |args| add_arg(args, parser, store_in) }
    end

    def apply(klass, method_name, args=[])
      not args.is_a? Array and args = [args]
      return [klass.method(method_name).to_proc, *args]
    end

    def main(template={})
      args = [
        # Assert hex
        ["--fg-normal=HEX", "Normal foreground color", Commandline.apply(Extras::Misc, "valid_hex?")],
        ["--bg-normal=HEX", "Normal background color", Commandline.apply(Extras::Misc, "valid_hex?")],
        ["--bg-focus=HEX", "Focused background color", Commandline.apply(Extras::Misc, "valid_hex?")],
        ["--fg-focus=HEX", "Focused foreground color", Commandline.apply(Extras::Misc, "valid_hex?")],
        ["--border-focus=HEX", "Focused client border color", Commandline.apply(Extras::Misc, "valid_hex?")],

        # Paths
        ['--wallpaper=PATH', "Wallpaper", Commandline.apply(Extras::PathOps, "valid_paths?")],

        # Normal stuf
        ["--tasklist-align=ALIGNMENT", "Tasklist title alignment", [:default]],
        ["--name=STR", "Name of the theme", [:default]],
        ["--tasklist-font-focus=PANGO", "Tasklist font for focused client", [:default]],

        # Misc
        ['--inject-lua=PATH', "Inject lua code in theme.lua", [:default]],
        ['--apply=REGEX', "Apply the first matching theme.", [:default]],
        ['--apply-with-rofi', "Use rofi to apply theme", [:default]],
      ]

      options = template
      parser = OptionParser.new("Usage: Theme awesomewm to a certain degree")
      Commandline.add_args(args, parser, options)
      parser.parse!
      options
    end
  end
end
