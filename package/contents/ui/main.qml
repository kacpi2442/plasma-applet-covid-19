/***************************************************************************
 *   Copyright (C) 2017 by MakG <makg@makg.eu>                             *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/covid.js" as Covid

Item {
	id: root
	
	Layout.fillHeight: true
	
	SystemPalette {
		id: palette
	}
	
	property string covidCases: '...'
	property bool showIcon: plasmoid.configuration.showIcon
	property bool showText: plasmoid.configuration.showText
	property bool formatNumber: plasmoid.configuration.formatNumber
	property bool updatingRate: false
	
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
		
		Layout.fillWidth: false
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
			running: updatingRate
			visible: updatingRate
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
			opacity: root.updatingRate ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
		}
		
		ColorOverlay {
			anchors.fill: virusIcon
			source: virusIcon
			color: palette.windowText
		}
		
		PlasmaComponents.Label {
			id: currentCases
			height: parent.height
			anchors.left: root.showIcon ? virusIcon.right : parent.left
			anchors.right: parent.right
			anchors.leftMargin: root.showIcon ? textMargin : 0
			
			horizontalAlignment: root.showIcon ? Text.AlignLeft : Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			
			visible: root.showText
			opacity: root.updatingRate ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
			
			fontSizeMode: Text.Fit
			minimumPixelSize: virusIcon.width * 0.7
			font.pixelSize: 72			
			text: root.covidCases
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
	
	function setRate(rate) {
		var rateText = (rate === null ? plasmoid.configuration.rate : Number(rate));
		if (root.formatNumber) rateText = (rate === null ? plasmoid.configuration.rate : Number(rate).toLocaleString(Qt.locale(), 'f', 0));
		plasmoid.configuration.rate = rateText;
		root.covidCases = rateText;
		
		var toolTipSubText = '<b>' + root.covidCases + '</b>';
		toolTipSubText += '<br />';
		toolTipSubText += i18n('Source:') + ' ' + plasmoid.configuration.source;
		
		plasmoid.toolTipSubText = toolTipSubText;
	}
	
	Timer {
		id: refreshTimer
		interval: plasmoid.configuration.refreshRate * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			root.updatingRate = true;
			refreshTimeout.start();
			
			var result = Covid.getRate(plasmoid.configuration.source, plasmoid.configuration.country, function(rate) {
				setRate(rate);
				root.updatingRate = false;
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
			root.updatingRate = false
		}
	}
	
	function action_refresh() {
		refreshTimer.restart();
	}
	
	function action_website() {
		Qt.openUrlExternally(Covid.getSourceByName(plasmoid.configuration.source).homepage);
	}
}
