# COVID-19 Cases Plasmoid

## About
Plasma applet showing the current COVID-19 Cases by chosen country.

## Installation
```
plasmapkg2 -i package
```

Use additional `-g` flag to install plasmoid globally, for all users.

## Screenshots
![COVID-19 Plasmoid](sh1.png)

![COVID-19 Plasmoid (Panel)](sh2.png)

![COVID-19 Plasmoid (Configuration)](sh3.png)

![COVID-19 Plasmoid (Configuration)](sh4.png)

## Changelog

### 1.2

- Fixed lmao.ninja data source

### 1.1
- Added option to format number count according to locale 
- Added request error handling and timeout
- Added support for pomber.github.io/covid19
- Changed default refresh rate to 20 minutes

### 1.0.2
- Displays now global cases by default
- New svg icon

### 1.0.1
- Added support for coronavirusapi.me

### 1.0
- Initial release
