const encodeUriComponent = require('encodeUriComponent');
const getRequestHeader = require('getRequestHeader');
const getType = require('getType');
const JSON = require('JSON');
const makeString = require('makeString');
const makeTableMap = require('makeTableMap');
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
