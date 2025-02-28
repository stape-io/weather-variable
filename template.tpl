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
  },
  {
    "type": "GROUP",
    "name": "logsGroup",
    "displayName": "Logs Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "RADIO",
        "name": "logType",
        "radioItems": [
          {
            "value": "no",
            "displayValue": "Do not log"
          },
          {
            "value": "debug",
            "displayValue": "Log to console during debug and preview"
          },
          {
            "value": "always",
            "displayValue": "Always log to console"
          }
        ],
        "simpleValueType": true,
        "defaultValue": "debug"
      }
    ]
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
    const city = data.city || getRequestHeader('X-Geo-City') || getRequestHeader('X-Gclb-Region');
    const country = data.countryCode || getRequestHeader('X-Geo-Country')|| getRequestHeader('X-Gclb-Country');
    if(city === 'XX' || city === 'ZZ' || !city) {
        return null;
    } else {
        return {
            city: city,
            country: country
        };
    }
}

const geo = getGeoInfo();
const url = apiUrl + "q=" + enc(geo.city) + ', ' + enc(geo.country) + "&appid=" + enc(apiKey) + "&units=" + enc(units);
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
            return {
                temperature: Math.ceil(parsedBody.main.temp),
                rain: parsedBody.rain ? parsedBody.rain['1h'] : 0
            };
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
                    "string": "trace-id"
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

Created on 15/02/2024, 17:22:27


