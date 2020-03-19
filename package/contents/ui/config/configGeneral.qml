import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import ".."
import "../../code/covid.js" as Covid

Item {
	id: configGeneral
	Layout.fillWidth: true
	property string cfg_source: plasmoid.configuration.source
	property string cfg_country: plasmoid.configuration.country
	property alias cfg_refreshRate: refreshRate.value
	property alias cfg_showIcon: showIcon.checked
	property alias cfg_showText: showText.checked
	property alias cfg_showBackground: showBackground.checked
	property alias cfg_formatNumber: formatNumber.checked
	property variant sourceList: { Covid.getAllSources() }
	property variant countryList: { Covid.getAllCountries() }

	GridLayout {
		columns: 2
		
		Label {
			text: i18n("Source:")
		}
		
		ComboBox {
			id: source
			model: sourceList
			Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 15
			onActivated: {
				cfg_source = source.textAt(index)
			}
			Component.onCompleted: {
				var sourceIndex = source.find(plasmoid.configuration.source)
				
				if(sourceIndex != -1) {
					source.currentIndex = sourceIndex
				}
			}
		}
		
		Label {
			text: i18n("Country:")
		}
		
		ComboBox {
			id: country
			model: countryList
			Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 15
			onActivated: {
				cfg_country = country.textAt(index)
			}
			Component.onCompleted: {
				var countryIndex = country.find(plasmoid.configuration.country)
				
				if(countryIndex != -1) {
					country.currentIndex = countryIndex
				}
			}
		}
		
		Label {
			text: i18n("Refresh rate:")
		}
		
		SpinBox {
			id: refreshRate
			suffix: i18n(" minutes")
			minimumValue: 1
		}
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: showIcon
			text: i18n("Show icon")
			onClicked: {
				if(!this.checked) {
					showText.checked = true
					showText.enabled = false
				} else {
					showText.enabled = true
				}
			}
		}
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: showText
			text: i18n("Show text (when disabled, the rate is visible on hover)")
			onClicked: {
				if(!this.checked) {
					showIcon.checked = true
					showIcon.enabled = false
				} else {
					showIcon.enabled = true
				}
			}
		}
		
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: showBackground
			text: i18n("Show background")
		}
		
		Label {
			text: ""
		}
		
		CheckBox {
			id: formatNumber
			text: i18n("Format number for locale")
		}
		
	}
}
