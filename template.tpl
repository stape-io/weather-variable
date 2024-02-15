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


const apiUrl = "https://api.openweathermap.org/data/2.5/weather?";
const units = data.units;
const apiKey = data.apiKey;

function getCity() {
  const cityFromHeaders = getRequestHeader('X-Geo-City');
  if(cityFromHeaders === 'ZZ' || !cityFromHeaders) {
    return "We couldn't determine your city";
  } else {
    return cityFromHeaders;
 }
}

const city = getCity();

const url = apiUrl + "q=" + enc(city) + "&appid=" + enc(apiKey) + "&units=" + enc(units);
return sendRequest(url);

function sendRequest(url) {
    return sendHttpRequest(url).then((successResult) => {
        if (successResult.statusCode === 301 || successResult.statusCode === 302) {
            return sendRequest(successResult);
        }
        const parsedBody = JSON.parse(successResult.body);
        const result = Math.ceil(parsedBody.main.temp);
        return result;
    });
}

function enc(data) {
    data = data || '';
    return encodeUriComponent(data);
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
  }
]


___TESTS___

scenarios:
- name: Quick Test
  code: runCode();
setup: ''


___NOTES___

Created on 15/02/2024, 17:22:27


