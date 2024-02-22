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
  "description": "Weather gives you the ability to get the air temperature in your city.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
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
    "help": "To get the key visit the https://openweathermap.org/ service."
  },
  {
    "type": "TEXT",
    "name": "city",
    "displayName": "City",
    "simpleValueType": true,
    "help": "Enter city name."
  },
  {
    "type": "TEXT",
    "name": "countryCode",
    "displayName": "Country code",
    "simpleValueType": true,
    "help": "Enter a 2 or 3-digit ISO code for the country.",
    "valueValidators": [
      {
        "type": "STRING_LENGTH",
        "args": [
          2,
          3
        ]
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "units",
    "displayName": "Select unit",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "imperial",
        "displayValue": "Fahrenheit"
      },
      {
        "value": "metric",
        "displayValue": "Celsius"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "imperial"
  }
]


___SANDBOXED_JS_FOR_SERVER___

const getRequestHeader = require('getRequestHeader');
const sendHttpRequest = require('sendHttpRequest');
const JSON = require('JSON');
const encodeUriComponent = require('encodeUriComponent');
const Math = require('Math');
const logToConsole = require('logToConsole');
const getContainerVersion = require('getContainerVersion');


const apiUrl = "https://api.openweathermap.org/data/2.5/weather?";
const units = data.units;
const apiKey = data.apiKey;
const isLoggingEnabled = determinateIsLoggingEnabled();
const traceId = isLoggingEnabled ? getRequestHeader('trace-id') : undefined;
function getGeoInfo() {
    const cityFromHeaders = data.city || getRequestHeader('X-Geo-City') ;
    const countryFromHeaders = data.countryCode || getRequestHeader('X-Geo-Country');
    if(cityFromHeaders === 'ZZ' ||  !cityFromHeaders) {
        return null;
    } else {
        return {
            city: cityFromHeaders,
            country: countryFromHeaders
        };
    }
}

const geo = getGeoInfo();
const geoCountry = geo.country ? ',' + geo.country : '';
const url = apiUrl + "q=" + enc(geo.city) + enc(geoCountry) + "&appid=" + enc(apiKey) + "&units=" + enc(units);
let postBody = null;
return sendRequest(url,postBody);

function sendRequest(url,postBody) {
    if (isLoggingEnabled) {
        logToConsole(
          JSON.stringify({
              Name: 'Weather',
              Type: 'Request',
              TraceId: traceId,
              EventName: 'WeatherRequest',
              RequestMethod: 'GET',
              RequestUrl: url,
          })
        );
        return sendHttpRequest(url).then((response) => {
            if (isLoggingEnabled) {
                logToConsole(
                  JSON.stringify({
                      Name: 'Weather',
                      Type: 'Response',
                      TraceId: traceId,
                      EventName: 'WeatherRequest',
                      ResponseStatusCode: response.statusCode,
                      ResponseHeaders: response.headers,
                      ResponseBody: response.body,
                  })
                );
            }
            if (response.statusCode === 301 || response.statusCode === 302) {
                return sendRequest(response);
            }
            const parsedBody = JSON.parse(response.body);
            return Math.ceil(parsedBody.main.temp);
        });
    }
}

function enc(data) {
    data = data || '';
    return encodeUriComponent(data);
}
function determinateIsLoggingEnabled() {
    const containerVersion = getContainerVersion();
    const isDebug = !!(containerVersion && (containerVersion.debugMode || containerVersion.previewMode));

    if (!data.logType) {
        return isDebug;
    }

    if (data.logType === 'no') {
        return false;
    }

    if (data.logType === 'debug') {
        return isDebug;
    }

    return data.logType === 'always';
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
            "string": "any"
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
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Quick Test
  code: runCode();
setup: ''


___NOTES___

Created on 19/02/2024, 17:35:58


