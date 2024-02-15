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
        return Math.ceil(parsedBody.main.temp);
    });
}

function enc(data) {
    data = data || '';
    return encodeUriComponent(data);
}