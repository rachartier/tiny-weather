#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CURRENT_DIR/helpers.sh"

get_forecast() {
	local language=$(get_tmux_option @tinyweather-language "en")
	local location=$(get_tmux_option @tinyweather-location "")
	local include_city=$(get_tmux_option @tinyweather-include-city false)

	local color_sunny=$(get_tmux_option @tinyweather-color-sunny "#ffff00")
	local color_cloudy=$(get_tmux_option @tinyweather-color-cloudy "#aaaaaa")
	local color_snowy=$(get_tmux_option @tinyweather-color-snowy "#ffffff")
	local color_rainny=$(get_tmux_option @tinyweather-color-rainny "#00aaff")
	local color_stormy=$(get_tmux_option @tinyweather-color-stormy "#ffaa00")
	local color_default=$(get_tmux_option @tinyweather-color-default "#ff0000")

	local weather_string=$(curl -s -H "Accepted-Language: $language" "wttr.in/$location?format=%x,%t,%s,%S,%l" | cut -d "," -f 1,2,3,4,5 | tr "," "\n")
	local weather_type=$(echo "$weather_string" | awk 'NR==1')
	local temperature_string=$(echo "$weather_string" | awk 'NR==2')
	local sunset=$(echo "$weather_string" | awk 'NR==3')
	local sunrise=$(echo "$weather_string" | awk 'NR==4')
	local city=$(echo "$weather_string" | awk 'NR==5')

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

	declare -A dict_weather_symbol_day=(
		["?"]=""
		["mm"]="󰖐"
		["mmm"]="󰖐"
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

	declare -A dict_weather_symbol_night=(
		["?"]=""
		["mm"]="󰖐"
		["mmm"]="󰖐"
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
		["m"]="󰼱"
		["o"]="󰖔"
		["/!/"]="󰙾"
		["!/"]="󰖓"
		["*!*"]="󰖒"
	)

	declare -A dict_weather_color_day=(
		["?"]="#[fg=$color_default]"
		["mm"]="#[fg=$color_cloudy]"
		["mmm"]="#[fg=$color_cloudy]"
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
	declare -A dict_weather_color_night=(
		["?"]="#[fg=$color_default]"
		["mm"]="#[fg=$color_cloudy]"
		["mmm"]="#[fg=$color_cloudy]"
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
		["o"]="#[fg=$color_cloudy]"
		["/!/"]="#[fg=$color_stormy]"
		["!/"]="#[fg=$color_stormy]"
		["*!*"]="#[fg=$color_stormy]"
	)

	local actual_date="$(date '+%H:%M:%S')"

	if [ "$include_city" = true ]; then
		echo -n "$city: "
	fi

	if [[ "$actual_date" > "$sunset" ]] || [[ "$actual_date" < "$sunrise" ]]; then
		echo "${dict_weather_color_night[$weather_type]}${dict_weather_symbol_night[$weather_type]} #[fg=$color_default]$temperature_string"
	else
		echo "${dict_weather_color_day[$weather_type]}${dict_weather_symbol_day[$weather_type]} #[fg=$color_default]$temperature_string"
	fi
}

get_cached_forecast() {
	local cache_duration=$(get_tmux_option @tinyweather-cache-duration 0)
	local cache_path=$(get_tmux_option @tinyweather-cache-path "/tmp/tiny-weather.cache")
	local cache_age=$(get_file_age "$cache_path")
	local forecast

	if [ "$cache_duration" -gt 0 ]; then
		if ! [ -f "$cache_path" ] || [ "$cache_age" -ge "$cache_duration" ]; then
			forecast=$(get_forecast)

			mkdir -p "$(dirname "$cache_path")"
			echo "$forecast" >"$cache_path"
		else
			forecast=$(cat "$cache_path" 2>/dev/null)
		fi
	else
		forecast=$(get_forecast)
	fi
	echo "$forecast"
}

print_forecast() {
	local char_limit=$(get_tmux_option @tinyweather-char-limit 75)
	local forecast=$(get_cached_forecast)
	echo "${forecast:0:$char_limit}"
}

main() {
	print_forecast
}

main
