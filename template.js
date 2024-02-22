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
