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
