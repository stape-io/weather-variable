___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Weather",
  "description": "Weather variable allow you to get weather data (air temperature, humidity etc.) in a city.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "GROUP",
    "name": "configGroup",
    "displayName": "",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "apiKey",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "displayName": "API Key",
        "help": "To get the key visit \u003ca href\u003d\"https://home.openweathermap.org/api_keys\" target\u003d\"_blank\"\u003e OpenWeather API Keys page\u003c/a\u003e."
      },
      {
        "type": "SELECT",
        "name": "units",
        "displayName": "Select unit system",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "imperial",
            "displayValue": "Imperial"
          },
          {
            "value": "metric",
            "displayValue": "Metric"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "imperial",
        "help": "Select unit system.\u003c/br\u003e \n\u003cul\u003e\n  \u003cli\u003e\u003cb\u003eImperial\u003c/b\u003e: speed in miles/hour and temperature in Fahrenheit\u003c/li\u003e\n  \u003cli\u003e\u003cb\u003eMetric\u003c/b\u003e: speed in meters/second and temperature in Celsius\u003c/li\u003e\n\u003c/ul\u003e"
      },
      {
        "type": "TEXT",
        "name": "countryCode",
        "displayName": "Country Code",
        "simpleValueType": true,
        "help": "Please provide a сountry and сity to get the temperature. If you use Stape or GCP App Engine Hosting for sGTM, then country and city will be detected automatically."
      },
      {
        "type": "TEXT",
        "name": "city",
        "displayName": "City",
        "simpleValueType": true,
        "help": "Please provide a сountry and сity to get the temperature. If you use Stape or GCP App Engine Hosting for sGTM, then country and city will be detected automatically."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "returnOptionsGroup",
    "displayName": "",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "SELECT",
        "name": "whatToReturn",
        "displayName": "What To Return",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "allData",
            "displayValue": "All Data"
          },
          {
            "value": "coord.lon",
            "displayValue": "Longitude"
          },
          {
            "value": "coord.lat",
            "displayValue": "Latitude"
          },
          {
            "value": "weather.0.description",
            "displayValue": "Weather Description"
          },
          {
            "value": "main.temp",
            "displayValue": "Temperature"
          },
          {
            "value": "main.feels_like",
            "displayValue": "Feels Like Temperature"
          },
          {
            "value": "main.pressure",
            "displayValue": "Pressure (hPa)"
          },
          {
            "value": "main.humidity",
            "displayValue": "Humidity (%)"
          },
          {
            "value": "main.temp_min",
            "displayValue": "Minimum Temperature"
          },
          {
            "value": "main.temp_max",
            "displayValue": "Maximum Temperature"
          },
          {
            "value": "visibility",
            "displayValue": "Visibility (meters)"
          },
          {
            "value": "wind.speed",
            "displayValue": "Wind Speed (meters/sec or miles/hr)"
          },
          {
            "value": "wind.gust",
            "displayValue": "Wind Gust (meters/sec or miles/hr)"
          },
          {
            "value": "clouds.all",
            "displayValue": "Cloudiness (%)"
          },
          {
            "value": "rain.1h",
            "displayValue": "Rain (mm/h)"
          },
          {
            "value": "snow.1h",
            "displayValue": "Snow (mm/h)"
          },
          {
            "value": "sys.sunrise",
            "displayValue": "Sunrise Time (seconds) - Unix [UTC]"
          },
          {
            "value": "sys.sunset",
            "displayValue": "Sunset Time (seconds) - Unix [UTC]"
          }
        ],
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "defaultValue": "main.temp",
        "alwaysInSummary": false,
        "help": "Choose a property to return. \u003c/br\u003e \nDefaults to \u003cb\u003eTemperature\u003c/b\u003e."
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const encodeUriComponent = require('encodeUriComponent');
const getRequestHeader = require('getRequestHeader');
const getType = require('getType');
const JSON = require('JSON');
const makeString = require('makeString');
const Math = require('Math');
const sendHttpRequest = require('sendHttpRequest');

/*==============================================================================
==============================================================================*/

const geo = getGeoInfo();
if (!geo) {
  return null;
}

const apiUrl = 'https://api.openweathermap.org/data/2.5/weather?';
const url =
  apiUrl +
  'q=' +
  enc(geo.city) +
  ', ' +
  enc(geo.country) +
  '&appid=' +
  enc(data.apiKey) +
  '&units=' +
  enc(data.units);

return sendRequest(url);

/*==============================================================================
  Vendor related functions
==============================================================================*/

function getGeoInfo() {
  const city = data.city || getRequestHeader('X-Geo-City') || getRequestHeader('X-Gclb-Region');
  const country =
    data.countryCode || getRequestHeader('X-Geo-Country') || getRequestHeader('X-Gclb-Country');
  if (city === 'XX' || city === 'ZZ' || !city) {
    return null;
  } else {
    return {
      city: city,
      country: country
    };
  }
}

function sendRequest(url) {
  return sendHttpRequest(url)
    .then((response) => {
      const parsedBody = JSON.parse(response.body || '{}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return parsedBody.message || 'Request failed';
      }

      const whatToReturn = data.whatToReturn || 'main.temp'; // Backwards compatibility.
      const returnAll = whatToReturn === 'allData';
      if (returnAll) return parsedBody;

      const returnValue = getNestedValue(parsedBody, whatToReturn.split('.'));
      return whatToReturn === 'main.temp' ? Math.ceil(returnValue) : returnValue; // Backwards compatibility.
    })
    .catch((exception) => 'Error' + (exception.reason ? ': ' + exception.reason : ''));
}

/*==============================================================================
  Helpers
==============================================================================*/

function enc(data) {
  if (['null', 'undefined'].indexOf(getType(data)) !== -1) data = '';
  return encodeUriComponent(makeString(data));
}

function getNestedValue(obj, pathArray) {
  return pathArray.reduce((acc, key) => {
    return getType(acc) !== 'undefined' && getType(acc) !== 'null' ? acc[key] : undefined;
  }, obj);
}


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "headerWhitelist",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "X-Geo-City"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "X-Geo-Country"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "X-Gclb-Region"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "headerName"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "X-Gclb-Country"
                  }
                ]
              }
            ]
          }
        },
        {
          "key": "headersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://api.openweathermap.org/data/2.5/weather*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: '[Early Exit] Returns null without calling sendHttpRequest when no valid city
    is found'
  code: |-
    [
      undefined,
      'XX',
      'ZZ',
      ''
    ].forEach((city) => {
      const copyMockData = createMockData({ city: city, countryCode: undefined });

      const variableResult = runCode(copyMockData);

      assertThat(variableResult).isNull();
      assertApi('sendHttpRequest').wasNotCalled();
    });
- name: '[Geo Resolution] Builds query using data fields then X-Geo headers then X-Gclb
    headers'
  code: |-
    [
      {
        dataOverrides: { city: 'Berlin', countryCode: 'DE' },
        headers: { 'X-Geo-City': 'Paris', 'X-Geo-Country': 'FR', 'X-Gclb-Region': 'Tokyo', 'X-Gclb-Country': 'JP' },
        expectedQuery: 'q=Berlin, DE'
      },
      {
        dataOverrides: { city: undefined, countryCode: undefined },
        headers: { 'X-Geo-City': 'London', 'X-Geo-Country': 'GB', 'X-Gclb-Region': 'Tokyo', 'X-Gclb-Country': 'JP' },
        expectedQuery: 'q=London, GB'
      },
      {
        dataOverrides: { city: undefined, countryCode: undefined },
        headers: { 'X-Gclb-Region': 'Tokyo', 'X-Gclb-Country': 'JP' },
        expectedQuery: 'q=Tokyo, JP'
      }
    ].forEach((scenario) => {
      const copyMockData = createMockData(scenario.dataOverrides);

      mock('getRequestHeader', (name) => scenario.headers[name]);
      mock('sendHttpRequest', (url) => {
        assertThat(url).contains(scenario.expectedQuery);
        return Promise.create((resolve) => resolve({ statusCode: 200, body: JSON.stringify(successBody) }));
      });

      runCode(copyMockData);
    });
- name: '[Request] Encodes special characters in city and apiKey and includes units
    in the URL'
  code: |-
    const copyMockData = createMockData({ city: 'Rio de Janeiro', apiKey: 'ab&cd=1', units: 'metric' });

    mock('sendHttpRequest', (url) => {
      assertThat(url).isEqualTo('https://api.openweathermap.org/data/2.5/weather?q=Rio%20de%20Janeiro, br&appid=ab%26cd%3D1&units=metric');
      return Promise.create((resolve) => resolve({ statusCode: 200, body: JSON.stringify(successBody) }));
    });

    runCode(copyMockData);
- name: '[Response Mapping] Extracts every whatToReturn path, including missing optional
    fields'
  code: |-
    [
      { path: 'coord.lon', expected: -0.13 },
      { path: 'coord.lat', expected: 51.51 },
      { path: 'weather.0.description', expected: 'light intensity drizzle' },
      { path: 'main.pressure', expected: 1012 },
      { path: 'main.humidity', expected: 81 },
      { path: 'main.temp_min', expected: 279.15 },
      { path: 'main.temp_max', expected: 281.15 },
      { path: 'visibility', expected: 10000 },
      { path: 'wind.speed', expected: 4.1 },
      { path: 'clouds.all', expected: 90 },
      { path: 'sys.sunrise', expected: 1485762037 },
      { path: 'sys.sunset', expected: 1485794875 },
      { path: 'main.feels_like', expected: undefined },
      { path: 'wind.gust', expected: undefined },
      { path: 'rain.1h', expected: undefined },
      { path: 'snow.1h', expected: undefined }
    ].forEach((scenario) => {
      const copyMockData = createMockData({ whatToReturn: scenario.path });

      runCode(copyMockData).then((variableResult) => {
        if (getType(scenario.expected) === 'undefined') {
          assertThat(variableResult).isUndefined();
        } else {
          assertThat(variableResult).isEqualTo(scenario.expected);
        }
      });
    });
- name: '[Response Mapping] Defaults to main temp and rounds it up when whatToReturn
    is not set'
  code: |-
    const copyMockData = createMockData({ whatToReturn: undefined });

    runCode(copyMockData).then((variableResult) => {
      assertThat(variableResult).isEqualTo(281);
    });
- name: '[Response Mapping] Returns the full parsed body when whatToReturn is allData'
  code: |-
    const copyMockData = createMockData({ whatToReturn: 'allData' });

    runCode(copyMockData).then((variableResult) => {
      assertThat(variableResult).isEqualTo(successBody);
    });
- name: '[Error Response] Returns the API error message on a non-200 status code'
  code: |-
    mock('sendHttpRequest', () => Promise.create((resolve) => resolve({
      statusCode: 401,
      body: JSON.stringify({ cod: 401, message: 'Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.' })
    })));

    runCode(createMockData()).then((variableResult) => {
      assertThat(variableResult).isEqualTo('Invalid API key. Please see https://openweathermap.org/faq#error401 for more info.');
    });
- name: '[Error Response] Returns a generic Request failed message when the error
    response has no message'
  code: |-
    mock('sendHttpRequest', () => Promise.create((resolve) => resolve({ statusCode: 500 })));

    runCode(createMockData()).then((variableResult) => {
      assertThat(variableResult).isEqualTo('Request failed');
    });
- name: '[Network Failure] Returns Error with the reason when the request promise
    rejects'
  code: |-
    mock('sendHttpRequest', () => Promise.create((resolve, reject) => reject({ reason: 'timed_out' })));

    runCode(createMockData()).then((variableResult) => {
      assertThat(variableResult).isEqualTo('Error: timed_out');
    });
- name: '[Network Failure] Returns a generic Error when the rejection has no reason'
  code: |-
    mock('sendHttpRequest', () => Promise.create((resolve, reject) => reject({})));

    runCode(createMockData()).then((variableResult) => {
      assertThat(variableResult).isEqualTo('Error');
    });
setup: |-
  const JSON = require('JSON');
  const Promise = require('Promise');
  const Object = require('Object');
  const getType = require('getType');

  const assign = (target, source) => {
    if (!source) return target;
    const keys = Object.keys(source);
    keys.forEach((key) => { target[key] = source[key]; });
    return target;
  };

  const successBody = {
    coord: { lon: -0.13, lat: 51.51 },
    weather: [
      { id: 300, main: 'Drizzle', description: 'light intensity drizzle', icon: '09d' }
    ],
    base: 'stations',
    main: { temp: 280.32, pressure: 1012, humidity: 81, temp_min: 279.15, temp_max: 281.15 },
    visibility: 10000,
    wind: { speed: 4.1, deg: 80 },
    clouds: { all: 90 },
    dt: 1485789600,
    sys: { type: 1, id: 5091, message: 0.0103, country: 'GB', sunrise: 1485762037, sunset: 1485794875 },
    id: 2643743,
    name: 'London',
    cod: 200
  };

  const baseMockData = {
    apiKey: 'test-api-key',
    units: 'imperial',
    countryCode: 'br',
    city: 'Capivari',
    whatToReturn: 'main.temp'
  };

  const createMockData = (overrides) => assign(assign({}, baseMockData), overrides);

  mock('getRequestHeader', () => undefined);

  mock('sendHttpRequest', () => {
    return Promise.create((resolve) => {
      resolve({ statusCode: 200, body: JSON.stringify(successBody) });
    });
  });


___NOTES___

2026-07-27 - Change Notes:
  - Broaden the variable description and improve API Key, Country Code and City help text (clearer GCP App Engine wording, added city help, link to the OpenWeather API Keys page)
  - Add comprehensive unit test coverage for geo resolution, request building, whatToReturn mapping, API error handling and network failures

2026-05-21 Change Notes:
 - Console logging removal.

Created on 15/02/2024, 17:22:27

