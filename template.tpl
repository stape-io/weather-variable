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
  "description": "Weather variable allow you to get the air temperature in your city.",
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
        "help": "To get the key visit the \u003ca href\u003d\"https://openweathermap.org\" target\u003d\"_blank\"\u003ehttps://openweathermap.org\u003c/a\u003e service."
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
        "help": "Please provide a сountry and сity to get the temperature. If you use Stape or AppEngine Hosting for sGTM, then country and city will be detected automatically."
      },
      {
        "type": "TEXT",
        "name": "city",
        "displayName": "City",
        "simpleValueType": true
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

scenarios: []
setup: ''


___NOTES___

2026-05-21 Change Notes:
 - Console logging removal.

Created on 15/02/2024, 17:22:27


