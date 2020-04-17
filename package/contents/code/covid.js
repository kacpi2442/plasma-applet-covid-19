var sources = [
	{
		name: 'corona.lmao.ninja',
		url: 'https://corona.lmao.ninja/v2/countries',
		method: "GET",
		requestBody: '',
		getRate: function(data, country) {
			if (country=="All"){
				var confirmed = 0
				for (var i = 0; i < data.length; i++){
					confirmed += data[i].cases;
				}
				return confirmed;
			}
			for (var i = 0; i < data.length; i++){
  				if (data[i].country == country){
					return data[i].cases;
 				}
			}
			return "0";
		}
	},
	{
		name: 'coronavirusapi.me',
		url: 'https://coronavirusapi.me',
		method: "POST",
		requestBody: '{"query":"{locations{region confirmed}}"}',
		getRate: function(data, country) {
			var confirmed = 0
			if (country=="All"){
				for (var i = 0; i < data.data.locations.length; i++){
					confirmed += data.data.locations[i].confirmed;
				}
				return confirmed;
			}
			if (country=="UK") country="United Kingdom";
			if (country=="UAE") country="United Arab Emirates";
			if (country=="Taiwan") country="Taiwan*";
			if (country=="Diamond Princess") country="Cruise Ship";
			if (country=="S. Korea") country="Korea, South";
			for (var i = 0; i < data.data.locations.length; i++){
  				if (data.data.locations[i].region == country){
						confirmed += data.data.locations[i].confirmed;
 					}
			}
			return confirmed;
		}
	},
	{
		name: 'pomber.github.io/covid19',
		url: 'https://pomber.github.io/covid19/timeseries.json',
		method: "GET",
		requestBody: '',
		getRate: function(data, country) {
			var confirmed = 0
			if (country=="All"){
				for (var i = 0; i < Object.keys(data).length; i++){
					confirmed += data[Object.keys(data)[i]][data[Object.keys(data)[i]].length-1].confirmed;
			 	}
				return confirmed;
			}
			if (country=="UK") country="United Kingdom";
			if (country=="UAE") country="United Arab Emirates";
			if (country=="Taiwan") country="Taiwan*";
			if (country=="Diamond Princess") country="Cruise Ship";
			if (country=="S. Korea") country="Korea, South";
			for (var i = 0; i < Object.keys(data).length; i++){
  				if (Object.keys(data)[i] == country){
					return data[Object.keys(data)[i]][data[Object.keys(data)[i]].length-1].confirmed;
 				}
			}
			return "0";
		}
	},
];


function getAllCountries() {
	return ["All","Afghanistan","Albania","Algeria","Andorra","Angola","Anguilla","Argentina","Armenia","Aruba","Australia","Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgium","Belize","Benin","Bermuda","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","British Virgin Islands","Brunei","Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Canada","Cape Verde","Cayman Islands","Chad","Channel Islands","Chile","China","Colombia","Congo","Cook Islands","Costa Rica","Cote D Ivoire","Croatia","Cruise Ship","Cuba","Cyprus","Czechia","Denmark","Diamond Princess","Djibouti","Dominica","Dominican Republic","Ecuador","Egypt","El Salvador","Equatorial Guinea","Estonia","Ethiopia","Faeroe Islands","Falkland Islands","Faroe Islands","Fiji","Finland","France","French Guiana","French Polynesia","French West Indies","Gabon","Gambia","Georgia","Germany","Ghana","Gibraltar","Greece","Greenland","Grenada","Guam","Guatemala","Guernsey","Guinea","Guinea Bissau","Guyana","Haiti","Honduras","Hong Kong","Hungary","Iceland","India","Indonesia","Iran","Iraq","Ireland","Isle of Man","Israel","Italy","Jamaica","Japan","Jersey","Jordan","Kazakhstan","Kenya","Kuwait","Kyrgyz Republic","Laos","Latvia","Lebanon","Lesotho","Liberia","Libya","Liechtenstein","Lithuania","Luxembourg","Macao","Macedonia","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Martinique","Mauritania","Mauritius","Mexico","Moldova","Monaco","Mongolia","Montenegro","Montserrat","Morocco","Mozambique","Namibia","Nepal","Netherlands","Netherlands Antilles","New Caledonia","New Zealand","Nicaragua","Niger","Nigeria","North Macedonia","Norway","Oman","Pakistan","Palestine","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Poland","Portugal","Puerto Rico","Qatar","Reunion","Romania","Russia","Rwanda","S. Korea","Saint Martin","Samoa","San Marino","Satellite","Saudi Arabia","Senegal","Serbia","Seychelles","Sierra Leone","Singapore","Slovakia","Slovenia","South Africa","Spain","Sri Lanka","St Lucia","St Vincent","St. Barth","St. Lucia","Sudan","Suriname","Swaziland","Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Timor L'Este","Togo","Tonga","Tunisia","Turkey","Turkmenistan","UAE","UK","USA","Uganda","Ukraine","Uruguay","Uzbekistan","Vatican City","Venezuela","Vietnam","Virgin Islands","Yemen","Zambia","Zimbabwe"]
}

function getRate(source, country, callback) {
	source = typeof source === 'undefined' ? getSourceByName('corona.lmao.ninja') : getSourceByName(source);
	
	if(source === null) return false;
	request(source.url, source.method, source.requestBody, function(data) {	
		try {
			data = JSON.parse(data);
			var rate = source.getRate(data, country);
			callback(rate);
		} catch (e) {
			callback(null);
		}
	});
	
	return true;
}

function getSourceByName(name) {
	for(var i = 0; i < sources.length; i++) {
		if(sources[i].name == name) {
			return sources[i];
		}
	}
	
	return null;
}

function getAllSources() {
	var sourceNames = [];
	
	for(var i = 0; i < sources.length; i++) {
		sourceNames.push(sources[i].name);
	}
	
	return sourceNames;
}

function request(url, type, params, callback) {
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function() {
		if(xhr.readyState === 4) {
			callback(xhr.responseText);
		}
	};
	xhr.open(type, url, true);
	xhr.setRequestHeader("Accept-Encoding", "gzip, deflate, br");
	xhr.setRequestHeader("Content-Type", "application/json");
	xhr.setRequestHeader("Accept", "application/json");
	xhr.send(params);
}
