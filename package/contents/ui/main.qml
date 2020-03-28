/***************************************************************************
 *   Copyright (C) 2017 by MakG <makg@makg.eu>                             *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/covid.js" as Covid

Item {
	id: root

	Layout.fillHeight: true
	
	property string covidCases: '...'
	property string covidDeaths: '...'
	property string country: plasmoid.configuration.country
	property bool showIcon: plasmoid.configuration.showIcon
	property bool showText: plasmoid.configuration.showText
	property bool showCases: plasmoid.configuration.showCases
	property bool showDeaths: plasmoid.configuration.showDeaths
	property bool formatNumber: plasmoid.configuration.formatNumber
	property bool updatingStats: false
	
	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
	Plasmoid.toolTipTextFormat: Text.RichText
	Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? "StandardBackground" : "NoBackground"
	
	Plasmoid.compactRepresentation: Item {
		property int textMargin: virusIcon.height * 0.25
		property int minWidth: {
			if(root.showIcon && root.showText) {
				return currentCases.paintedWidth + virusIcon.width + textMargin;
			}
			else if(root.showIcon) {
				return virusIcon.width;
			} else {
				return currentCases.paintedWidth
			}
		}
		
		property int fontSize: {
			if(root.showCases && root.showDeaths) {
				return 30;
			} else {
				return 50;
			}
		}
		
		Layout.fillWidth: true
		Layout.minimumWidth: minWidth

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			onClicked: {
				switch(plasmoid.configuration.onClickAction) {
					case 'website':
						action_website();
						break;
					
					case 'refresh':
					default:
						action_refresh();
						break;
				}
			}
		}
		
		BusyIndicator {
			width: parent.height
			height: parent.height
			anchors.horizontalCenter: root.showIcon ? virusIcon.horizontalCenter : currentCases.horizontalCenter
			running: updatingStats
			visible: updatingStats
		}
		
		Image {
			id: virusIcon
			width: parent.height * 0.9
			height: parent.height * 0.9
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.topMargin: parent.height * 0.05
			anchors.leftMargin: root.showText ? parent.height * 0.05 : 0
			
			source: "../images/virus.svg"
			visible: root.showIcon
			opacity: root.updatingStats ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
		}
		
		PlasmaComponents.Label {
			id: currentCases
			height: parent.height
			anchors.left: root.showIcon ? virusIcon.right : parent.left
			anchors.right: parent.right
			anchors.leftMargin: root.showIcon ? textMargin : 0
			
			horizontalAlignment: root.showIcon ? Text.AlignLeft : Text.AlignHCenter
			verticalAlignment: root.showDeaths ? Text.AlignTop : Text.AlignVCenter
			
			visible: root.showText && root.showCases
			opacity: root.updatingStats ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
			
			fontSizeMode: Text.Fit
			minimumPixelSize: virusIcon.width * 0.7
			font.pixelSize: fontSize
			text: root.covidCases
		}

		PlasmaComponents.Label {
			id: currentDeaths
			height: parent.height
			anchors.left: root.showIcon ? virusIcon.right : parent.left
			anchors.right: parent.right
			anchors.leftMargin: root.showIcon ? textMargin : 0

			horizontalAlignment: root.showIcon ? Text.AlignLeft : Text.AlignHCenter
			verticalAlignment: root.showCases ? Text.AlignBottom : Text.AlignVCenter

			visible: root.showText && root.showDeaths
			opacity: root.updatingStats ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0

			fontSizeMode: Text.Fit
			minimumPixelSize: virusIcon.width * 0.7
			font.pixelSize: fontSize
			text: root.covidDeaths
		}
	}
	
	Component.onCompleted: {
		plasmoid.setAction('refresh', i18n("Refresh"), 'view-refresh')
	}
	
	Connections {
		target: plasmoid.configuration

		onCountryChanged: {
			refreshTimer.restart();
		}
		onSourceChanged: {
			refreshTimer.restart();
		}
		onRefreshRateChanged: {
			refreshTimer.restart();
		}
		onFormatNumberChanged: {
			refreshTimer.restart();
		}
	}

	function updateStats(source, country, callback) {
		Covid.getRate(source, country, function(rate) {
			setRate(rate, function(rateText) {
				Covid.getDeaths(source, country, function(deaths) {
					setDeaths(deaths, function(deathsText) {
						var toolTipSubText = "<b> Cases: " + rateText + "<br />";
						toolTipSubText += "Deaths: " + deathsText + "</b>";
						toolTipSubText += "<br /> Country: " + root.country + "<br />";
						toolTipSubText += i18n("Source:") + ' ' + plasmoid.configuration.source;
						
						plasmoid.toolTipSubText = toolTipSubText;

						toolTipSubText += "Deaths: " + root.covidDeaths + "</b>";

						callback(true);
					});
				});
			});
		});
	}
	
	function setRate(rate, callback) {
		var rateText = (rate === null ? plasmoid.configuration.rate : Number(rate));
		if (root.formatNumber) rateText = (rate === null ? plasmoid.configuration.rate : Number(rate).toLocaleString(Qt.locale(), 'f', 0));
		plasmoid.configuration.rate = rateText;
		root.covidCases = root.showText ? "Cases: " + rateText : "";
		callback(rateText);
	}

	function setDeaths(deaths, callback) {
		var deathsText = (deaths === null ? plasmoid.configuration.deaths : Number(deaths));
		if(root.formatNumber) deathsText = (deaths === null ? plasmoid.configuration.deaths : Number(deaths).toLocaleString(Qt.locale(), "f", 0));
		plasmoid.configuration.deaths = deathsText;
		root.covidDeaths = root.showText ? "Deaths: " + deathsText : "";
		callback(deathsText);
	}
	
	Timer {
		id: refreshTimer
		interval: plasmoid.configuration.refreshRate * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			root.updatingStats = true;
			refreshTimeout.start();
			
			var result = updateStats(plasmoid.configuration.source, plasmoid.configuration.country, function(status) {
				root.updatingStats = false;
				refreshTimeout.stop();
			});
		}
	}
	
	Timer {
		id: refreshTimeout
		interval: 30000
		repeat: false
		onTriggered: {
			setRate(null);
			root.updatingStats = false
		}
	}
	
	function action_refresh() {
		refreshTimer.restart();
	}
	
	function action_website() {
		Qt.openUrlExternally(Covid.getSourceByName(plasmoid.configuration.source).homepage);
	}
}
