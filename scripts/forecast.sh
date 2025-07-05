#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$CURRENT_DIR/helpers.sh"

# Location helpers
get_lat_lon() {
    local lat=$(get_tmux_option @tinyweather-lat "")
    local lon=$(get_tmux_option @tinyweather-lon "")
    if [ -z "$lat" ] || [ -z "$lon" ]; then
        local coord=$(curl -s https://ipinfo.io/loc)
        lat=$(echo "$coord" | cut -d',' -f1)
        lon=$(echo "$coord" | cut -d',' -f2)
    fi
    echo "$lat,$lon"
}

# Weather API
fetch_weather_json() {
    local lat="$1"
    local lon="$2"
    curl -s "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true"
}

# Emoji selection
get_weather_emoji() {
    local wmo_code="$1"
    local is_day="$2"
    local emoji="?"
    case $wmo_code in
    0) emoji="󰖙" ;;
    1) emoji="" ;;
    2) emoji="󰖐" ;;
    3) emoji="" ;;
    45) emoji="󰖑" ;;
    48) emoji="" ;;
    51) emoji="" ;;
    53) emoji="" ;;
    55) emoji="" ;;
    56) emoji="" ;;
    57) emoji="" ;;
    61) emoji="" ;;
    63) emoji="" ;;
    65) emoji="" ;;
    66) emoji="" ;;
    67) emoji="" ;;
    71) emoji="" ;;
    73) emoji="" ;;
    75) emoji="" ;;
    77) emoji="" ;;
    80) emoji="" ;;
    81) emoji="" ;;
    82) emoji="" ;;
    85) emoji="" ;;
    86) emoji="" ;;
    95) emoji="" ;;
    96) emoji="" ;;
    99) emoji="" ;;
    *) emoji="" ;;
    esac
    if [ "$is_day" = "0" ]; then
        case $wmo_code in
        0) emoji="" ;;
        1) emoji="" ;;
        2) emoji="" ;;
        esac
    fi
    echo "$emoji"
}

# Color selection
get_color_key() {
    local wmo_code="$1"
    case $wmo_code in
    0) echo "clear" ;;
    1) echo "mainly_clear" ;;
    2) echo "partly_cloudy" ;;
    3) echo "overcast" ;;
    45 | 48) echo "fog" ;;
    51 | 53 | 55) echo "drizzle" ;;
    56 | 57) echo "freezing_drizzle" ;;
    61 | 63 | 65) echo "rain" ;;
    66 | 67) echo "freezing_rain" ;;
    71 | 73 | 75) echo "snow" ;;
    77) echo "snow_grains" ;;
    80 | 81 | 82) echo "rain_showers" ;;
    85 | 86) echo "snow_showers" ;;
    95 | 96 | 99) echo "thunderstorm" ;;
    *) echo "unknown" ;;
    esac
}

get_weather_color() {
    local color_key="$1"
    local is_day="$2"
    local color_sunny=$(get_tmux_option @tinyweather-color-sunny "#ffff00")
    local color_cloudy=$(get_tmux_option @tinyweather-color-cloudy "#aaaaaa")
    local color_snowy=$(get_tmux_option @tinyweather-color-snowy "#ffffff")
    local color_rainny=$(get_tmux_option @tinyweather-color-rainny "#00aaff")
    local color_stormy=$(get_tmux_option @tinyweather-color-stormy "#ffaa00")
    local color_default=$(get_tmux_option @tinyweather-color-default "#ff0000")

    declare -A dict_weather_color_day=(
        ["unknown"]="#[fg=$color_default]"
        ["mainly_clear"]="#[fg=$color_cloudy]"
        ["partly_cloudy"]="#[fg=$color_cloudy]"
        ["overcast"]="#[fg=$color_cloudy]"
        ["fog"]="#[fg=$color_cloudy]"
        ["drizzle"]="#[fg=$color_rainny]"
        ["freezing_drizzle"]="#[fg=$color_snowy]"
        ["rain"]="#[fg=$color_rainny]"
        ["freezing_rain"]="#[fg=$color_snowy]"
        ["snow"]="#[fg=$color_snowy]"
        ["snow_grains"]="#[fg=$color_snowy]"
        ["rain_showers"]="#[fg=$color_rainny]"
        ["snow_showers"]="#[fg=$color_snowy]"
        ["clear"]="#[fg=$color_sunny]"
        ["thunderstorm"]="#[fg=$color_stormy]"
    )
    declare -A dict_weather_color_night=(
        ["unknown"]="#[fg=$color_default]"
        ["mainly_clear"]="#[fg=$color_cloudy]"
        ["partly_cloudy"]="#[fg=$color_cloudy]"
        ["overcast"]="#[fg=$color_cloudy]"
        ["fog"]="#[fg=$color_cloudy]"
        ["drizzle"]="#[fg=$color_rainny]"
        ["freezing_drizzle"]="#[fg=$color_snowy]"
        ["rain"]="#[fg=$color_rainny]"
        ["freezing_rain"]="#[fg=$color_snowy]"
        ["snow"]="#[fg=$color_snowy]"
        ["snow_grains"]="#[fg=$color_snowy]"
        ["rain_showers"]="#[fg=$color_rainny]"
        ["snow_showers"]="#[fg=$color_snowy]"
        ["clear"]="#[fg=$color_cloudy]"
        ["thunderstorm"]="#[fg=$color_stormy]"
    )
    if [ "$is_day" = "0" ]; then
        echo "${dict_weather_color_night[$color_key]}"
    else
        echo "${dict_weather_color_day[$color_key]}"
    fi
}

# Temperature formatting
format_temperature() {
    local temp="$1"
    if [[ "${temp:0:1}" != "-" ]]; then
        echo "+${temp}°C"
    else
        echo "${temp}°C"
    fi
}

# Main forecast logic
generate_forecast() {
    IFS="," read -r lat lon <<<"$(get_lat_lon)"
    local weather_json=$(fetch_weather_json "$lat" "$lon")
    local wmo_code=$(echo "$weather_json" | jq -r '.current_weather.weathercode')
    local is_day=$(echo "$weather_json" | jq -r '.current_weather.is_day')
    local temp=$(echo "$weather_json" | jq -r '.current_weather.temperature')
    local temperature_string=$(format_temperature "$temp")
    local weather_emoji=$(get_weather_emoji "$wmo_code" "$is_day")
    local color_key=$(get_color_key "$wmo_code")
    local weather_color=$(get_weather_color "$color_key" "$is_day")
    local color_default=$(get_tmux_option @tinyweather-color-default "#ff0000")
    echo "$weather_color $weather_emoji#[fg=$color_default] $temperature_string"
}

# Caching
get_cached_forecast() {
    local cache_duration=$(get_tmux_option @tinyweather-cache-duration 0)
    local cache_path=$(get_tmux_option @tinyweather-cache-path "/tmp/tiny-weather.cache")
    local cache_age=$(get_file_age "$cache_path")
    local forecast
    if [ "$cache_duration" -gt 0 ]; then
        if ! [ -f "$cache_path" ] || [ "$cache_age" -ge "$cache_duration" ]; then
            forecast=$(generate_forecast)
            if mkdir -p "$(dirname "$cache_path")"; then
                if echo "$forecast" >"$cache_path"; then
                    :
                else
                    echo "Error writing forecast to cache file." >&2
                fi
            else
                echo "Error creating cache directory." >&2
            fi
        else
            forecast=$(cat "$cache_path" 2>/dev/null)
        fi
    else
        forecast=$(generate_forecast)
    fi
    echo "$forecast"
}

# Output
print_forecast() {
    local char_limit=$(get_tmux_option @tinyweather-char-limit 75)
    local forecast=$(get_cached_forecast)
    echo "${forecast:0:$char_limit}"
}

main() {
    print_forecast
}

main
