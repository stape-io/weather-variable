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
  return sendHttpRequest(url).then((response) => {
    if (response.statusCode === 301 || response.statusCode === 302) {
      return sendRequest(response);
    }
    const parsedBody = JSON.parse(response.body);
    return Math.ceil(parsedBody.main.temp);
  });
}

/*==============================================================================
  Helpers
==============================================================================*/

function enc(data) {
  if (['null', 'undefined'].indexOf(getType(data)) !== -1) data = '';
  return encodeUriComponent(makeString(data));
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
            "string": "any"
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
- name: Quick Test
  code: runCode();
setup: ''


___NOTES___

2026-05-21 Change Notes:
 - Console logging removal.

Created on 15/02/2024, 17:22:27

