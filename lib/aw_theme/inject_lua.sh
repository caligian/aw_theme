#!/usr/bin/env bash

read -r -d '' HELP <<< "
Usage: Inject required lua code for enabling user themes defined in json.
\$1: theme.lua path
"

[[ $1 =~ -h(elp)? ]] && echo "$HELP" && exit 0

# Madatorily requires awesome-copycat themes
theme_lua="${1:-$HOME/.config/awesome/themes/powerarrow-dark/theme.lua}"

require_loc=$(egrep -n 'require' "$theme_lua" | head -n 1 | cut -d ':' -f 1)
require_loc=$[require_loc - 1]

return_loc=$(egrep -n 'return theme' "$theme_lua" | cut -d ':' -f 1)
return_loc=$[return_loc - 1]

return_s=$(cat <<-'EOF'
local loc = os.getenv('HOME') .. '/.config/awesome/current_user_theme.json'
local FH = io.open(loc, 'r')

io.input(FH)
local lines = io.read('*all'); FH:close()
local t = json.decode(lines)

if FH then
    for k, v in pairs(t) do
        if v then
           theme[k] = v
        end
    end
end
EOF
           )


# Add lunajson
sed -i '/local gears = require("gears")/alocal json = require("lunajson")' $theme_lua 

# Add the json overwrite script
till_return="$(cat $theme_lua | head -n $return_loc)"
till_return="${till_return}\n\n${return_s}\n\nreturn theme"

echo "$till_return" > $theme_lua
