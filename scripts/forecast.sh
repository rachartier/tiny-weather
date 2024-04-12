#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"

get_forecast() {
	local language=$(get_tmux_option @tinyweather-language "en")
	local location=$(get_tmux_option @tinyweather-location "")

    local color_sunny=$(get_tmux_option @tinyweather-color-sunny "#ffff00")
    local color_cloudy=$(get_tmux_option @tinyweather-color-cloudy "#aaaaaa")
    local color_snowy=$(get_tmux_option @tinyweather-color-snowy "#ffffff")
    local color_rainny=$(get_tmux_option @tinyweather-color-rainny "#00aaff")
    local color_stormy=$(get_tmux_option @tinyweather-color-stormy "#ffaa00")
    local color_default=$(get_tmux_option @tinyweather-color-default "#ff0000")

    local weather_string=$(curl -s -H "Accepted-Language: $language" "wttr.in/$location?format=%x,%t" | cut -d "," -f 1,2 | tr "," "\n")
    local weather_type=$(echo "$weather_string" | awk 'NR==1')
    local temperature_string=$(echo "$weather_string" | awk 'NR==2')

    # "Unknown":             "",
    # "Cloudy":              "",
    # "Fog":                 "",
    # "HeavyRain":           "",
    # "HeavyShowers":        "",
    # "HeavySnow":           "",
    # "HeavySnowShowers":    "",
    # "LightRain":           "",
    # "LightShowers":        "",
    # "LightSleet":          "",
    # "LightSleetShowers":   "",
    # "LightSnow":           "",
    # "LightSnowShowers":    "",
    # "PartlyCloudy":        "",
    # "Sunny":               "",
    # "ThunderyHeavyRain":   "",
    # "ThunderyShowers":     "",
    # "ThunderySnowShowers": "",
    #
    # "Unknown":             "?",
    # "Cloudy":              "mm",
    # "Fog":                 "=",
    # "HeavyRain":           "///",
    # "HeavyShowers":        "//",
    # "HeavySnow":           "**",
    # "HeavySnowShowers":    "*/*",
    # "LightRain":           "/",
    # "LightShowers":        ".",
    # "LightSleet":          "x",
    # "LightSleetShowers":   "x/",
    # "LightSnow":           "*",
    # "LightSnowShowers":    "*/",
    # "PartlyCloudy":        "m",
    # "Sunny":               "o",
    # "ThunderyHeavyRain":   "/!/",
    # "ThunderyShowers":     "!/",
    # "ThunderySnowShowers": "*!*",
    # "VeryCloudy": "mmm",

    declare -A dict_weather_symbol=(
        ["?"]=""
        ["mm"]="󰖐"
        ["="]="󰖑"
        ["///"]="󰖖"
        ["//"]="󰖗"
        ["**"]="󰼶"
        ["*/*"]="󰙿"
        ["/"]="󰼳"
        ["."]="󰼳"
        ["x"]="󰼴"
        ["x/"]="󰼵"
        ["*"]="󰼴"
        ["*/"]="󰼵"
        ["m"]=""
        ["o"]="󰖙"
        ["/!/"]="󰙾"
        ["!/"]="󰖓"
        ["*!*"]="󰖒"
    )

    declare -A dict_weather_color=(
        ["?"]="#[fg=$color_default]"
        ["mm"]="#[fg=$color_cloudy]"
        ["="]="#[fg=$color_cloudy]"
        ["///"]="#[fg=$color_rainny]"
        ["//"]="#[fg=$color_rainny]"
        ["**"]="#[fg=$color_snowy]"
        ["*/*"]="#[fg=$color_snowy]"
        ["/"]="#[fg=$color_rainny]"
        ["."]="#[fg=$color_rainny]"
        ["x"]="#[fg=$color_snowy]"
        ["x/"]="#[fg=$color_snowy]"
        ["*"]="#[fg=$color_snowy]"
        ["*/"]="#[fg=$color_snowy]"
        ["m"]="#[fg=$color_cloudy]"
        ["o"]="#[fg=$color_sunny]"
        ["/!/"]="#[fg=$color_stormy]"
        ["!/"]="#[fg=$color_stormy]"
        ["*!*"]="#[fg=$color_stormy]"
    )
    echo "${dict_weather_color[$weather_type]}${dict_weather_symbol[$weather_type]} #[fg=$color_default]$temperature_string"
}

get_cached_forecast() {
	local cache_duration=$(get_tmux_option @tinyweather-cache-duration 0)                 # in seconds, by default cache is disabled
	local cache_path=$(get_tmux_option @tinyweather-cache-path "/tmp/tmux-weather.cache") # where to store the cached data
	local cache_age=$(get_file_age "$cache_path")
	local forecast
	if [ $cache_duration -gt 0 ]; then # Cache enabled branch
		if ! [ -f "$cache_path" ] || [ $cache_age -ge $cache_duration ]; then
			forecast=$(get_forecast)
			# store forecast in $cache_path
			mkdir -p "$(dirname "$cache_path")"
			echo "$forecast" >"$cache_path"
		else
			forecast=$(cat "$cache_path" 2>/dev/null)
		fi
	else # Cache disabled branch
		forecast=$(get_forecast)
	fi
	echo "$forecast"
}

print_forecast() {
	local char_limit=$(get_tmux_option @tinyweather-char-limit 75)
	local forecast=$(get_cached_forecast)
	echo ${forecast:0:$char_limit}
}

main() {
	print_forecast
}

main
