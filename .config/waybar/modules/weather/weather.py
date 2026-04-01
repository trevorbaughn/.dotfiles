#!/usr/bin/env python3

import requests
import jinja2

import weather_conf

# define icons
#  icons = {
#      'clear': "",
#      'clouds': "",
#      'rain': "",
#      'thunderstorm': "",
#      'snow': "",
#      'fog': ""
#  }

icons = {
    # clear
    800: '',  # clear sky

    # clouds
    801: '',  # few clouds: 11-25%
    802: '',  # scattered clouds: 25-50%
    803: '',  # broken clouds: 51-84%
    804: '',  # overcast clouds: 85-100%

    # drizzle
    300: '',  # light intensity drizzle
    301: '',  # drizzle
    302: '',  # heavy intensity drizzle
    310: '',  # light intensity drizzle rain
    311: '',  # drizzle rain
    312: '',  # heavy intensity drizzle rain
    313: '',  # shower rain and drizzle
    314: '',  # heavy shower rain and drizzle
    321: '',  # shower drizzle

    # rain
    500: '',  # light rain
    501: '',  # moderate rain
    502: '',  # heavy intensity rain
    503: '',  # very heavy rain
    504: '',  # extreme rain
    511: '',  # freezing rain
    520: '',  # light intensity shower rain
    521: '',  # shower rain
    522: '',  # heavy intensity shower rain
    531: '',  # ragged shower rain

    # thunderstorm
    200: '',  # thunderstorm with light rain
    201: '',  # thunderstorm with rain
    202: '',  # thunderstorm with heavy rain
    210: '',  # light thunderstorm
    211: '',  # thunderstorm
    212: '',  # heavy thunderstorm
    221: '',  # ragged thunderstorm
    230: '',  # thunderstorm with light drizzle
    231: '',  # thunderstorm with drizzle
    232: '',  # thunderstorm with heavy drizzle

    # snow
    600: '',  # light snow
    601: '',  # Snow
    602: '',  # Heavy snow
    611: '',  # Sleet
    612: '',  # Light shower sleet
    613: '',  # Shower sleet
    615: '',  # Light rain and snow
    616: '',  # Rain and snow
    620: '',  # Light shower snow
    621: '',  # Shower snow
    622: '',  # Heavy shower snow

    # atmosphere
    701: '',  # mist
    711: '',  # smoke
    721: '',  # haze
    731: '',  # sand/dust whirls
    741: '',  # fog
    751: '',  # sand
    761: '',  # dust
    762: '',  # volcanic ash
    771: '',  # sqalls
    781: '',  # tornado
}


class _WeatherInfo():
    def __init__(self, raw_json_data):
        raw_weather = raw_json_data["weather"][0]
        raw_main = raw_json_data["main"]

        self._condition_id = raw_weather["id"]
        self.description_short = raw_weather["main"].lower()
        self.description_long = raw_weather["description"]
        self.temperature = raw_main["temp"]
        self.temperature_min = raw_main["temp_min"]
        self.temperature_max = raw_main["temp_max"]
        self.pressure = raw_main["pressure"]
        self.humidity = raw_main["humidity"]
        self.icon = icons[self._condition_id]


class WeatherMan(object):
    def __init__(self, owm_api_key, city_id=None, units='metric'):
        self._api_key = owm_api_key
        self._units = units

        self._city_id = city_id

        self.city = ""
        self.current = None
        self.next = None

        self._get_weather()

    def _get_weather(self):
        params = {
            'units': self._units,
            'appid': self._api_key,
            'id': self._city_id,
        }
        r = requests.get(
            "http://api.openweathermap.org/data/2.5/forecast", params=params)
        d = r.json()

        if d['cod'] != '200':
            raise Exception("cannot get weather forecast", d['message'])

        self.city = d["city"]["name"]
        self.current = _WeatherInfo(d["list"][0])
        self.next = _WeatherInfo(d["list"][1])


def main(appid, city_id):
    template = '{"text": "{{current.icon}} {{current.temperature}}°C", "alt": "{{city}}: {{current.temperature}}°C, {{current.description_long}} -> {{next.temperature}}°C, {{next.description_long}}", "tooltip": "{{city}}: {{current.temperature_min}}°C -> {{current.temperature_max}}°C"}'
    weather = WeatherMan(appid, city_id)
    t = jinja2.Template(template)
    print(t.render(city=weather.city, current=weather.current,
                   next=weather.next))


if __name__ == "__main__":
    main(weather_conf.api_key, weather_conf.city_id)
