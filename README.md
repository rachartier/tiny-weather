# :cloud: tiny-weather

A tmux plugin to display weather information in your tmux status line.

Example:

![image](https://github.com/rachartier/tiny-weather/assets/2057541/4e612cb1-1de4-4603-8427-d69a70830513)


With city:

![image](https://github.com/rachartier/tiny-weather/assets/2057541/bb01019e-bbde-4ec8-b4c8-d38c7e643442)


## :rocket: Getting Started 

You need to have a nerd font !

### :wrench: Installing Manually

1. Clone the repo to your local machine
```sh
git clone https://github.com/user/tiny-weather.git ~/.tmux/plugins/tiny-weather
```
2. Add the following line to the bottom of your `.tmux.conf`
```sh
run-shell ~/.tmux/plugins/tiny-weather/tinyweather.tmux
```
3. Reload TMUX environment
```sh
tmux source-file ~/.tmux.conf
```

### :package: Installing with TPM (Tmux Plugin Manager) 

If you're using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm), you can install tiny-weather with the following steps:

1. Add the following line to your `.tmux.conf` file:
```sh
set -g @plugin 'user/tiny-weather'
```
2. Press `prefix + I` (capital i, as in **I**nstall) to fetch and install tiny-weather.

Now, tiny-weather should be installed and you should be able to see the weather information in your tmux status line.

### :gear: Configuration

You can customize the behavior of tiny-weather by setting the following options in your `.tmux.conf` file:

- `@tinyweather-language` - Language of the weather forecast. Default is "en".
- `@tinyweather-location` - Location for the weather forecast. Default is empty.
- `@tinyweather-cache-duration` - Duration of the cache in seconds. Default is 0 (cache disabled).
- `@tinyweather-cache-path` - Path to store the cache data. Default is "/tmp/tiny-weather.cache".
- `@tinyweather-include-city` - Includes the city name (true/false). Default is false.
- `@tinyweather-char-limit` - Set a limit to the number of characters displayed. Default is 75.

For example, to set the language to French and the location to Paris, you would add the following lines to your `.tmux.conf`:

```sh
set -g @tinyweather-language "fr"
set -g @tinyweather-location "Paris"
```

You can also customize the colors of the weather display by setting the following options in your `.tmux.conf` file:

- `@tinyweather-color-sunny` - Color for sunny weather. Default is yellow.
- `@tinyweather-color-snowy` - Color for snowy weather. Default is white.
- `@tinyweather-color-cloudy` - Color for cloudy weather. Default is foreground color.
- `@tinyweather-color-stormy` - Color for stormy weather. Default is orange.
- `@tinyweather-color-rainny` - Color for rainy weather. Default is blue.
- `@tinyweather-color-default` - Default color. Default is foreground color.

For example, you would add the following lines to your `.tmux.conf`:

```sh
set -g @tinyweather-color-sunny "#FFFF00"
set -g @tinyweather-color-rainny"#0000FF"
```

Now you can set the status:

```sh
set -g status-right "#{tinyweather}"
```

## :computer: Usage

Once installed and configured, tiny-weather will automatically display weather information in your tmux status line. The weather information is updated according to the cache duration you set.

