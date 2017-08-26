/***************************************************************************
 *   Copyright (C) %{CURRENT_YEAR} by %{AUTHOR} <%{EMAIL}>                            *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../code/bitcoin.js" as Bitcoin

Item {
	id: root
	
	width: units.gridUnit * 10
	height: units.gridUnit * 2
	
	property string bitcoinRate: '...'
	property bool showIcon: plasmoid.configuration.showIcon
	property bool updatingRate: false
	
	Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation
	Plasmoid.toolTipTextFormat: Text.RichText
	
	Plasmoid.compactRepresentation: Item {
		Layout.fillWidth: true

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
			anchors.horizontalCenter: root.showIcon ? bitcoinIcon.horizontalCenter : bitcoinValue.horizontalCenter
			running: updatingRate
			visible: updatingRate
		}
		
		Image {
			id: bitcoinIcon
			width: parent.height * 0.9
			height: parent.height * 0.9
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.topMargin: parent.height * 0.05
			anchors.leftMargin: parent.height * 0.05
			
			source: "../images/bitcoin.svg"
			visible: root.showIcon
			opacity: root.updatingRate ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
			
			states: State {
				name: "mouseover"
				PropertyChanges { target: bitcoinIcon; opacity: 0.5; rotation: 180 }
			}
			
			transitions: Transition {
				from: "*"; to: "mouseover"
				NumberAnimation { properties: "opacity,rotation"; easing.type: Easing.OutBounce; duration: 2000 }
			}
		}
		
		PlasmaComponents.Label {
			id: bitcoinValue
			height: parent.height
			anchors.left: root.showIcon ? bitcoinIcon.right : parent.left
			anchors.right: parent.right
			anchors.leftMargin: root.showIcon ? 10 : 0
			
			horizontalAlignment: root.showIcon ? Text.AlignLeft : Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			
			opacity: root.updatingRate ? 0.2 : mouseArea.containsMouse ? 0.8 : 1.0
			
			fontSizeMode: Text.Fit
			minimumPixelSize: 10
			font.pixelSize: 72			
			text: root.bitcoinRate
		}
	}
	
	Component.onCompleted: {
		plasmoid.setAction('refresh', i18n("Refresh"), 'view-refresh')
		plasmoid.setAction('website', i18n("Open market's website"), 'internet-services')
	}
	
	Connections {
		target: plasmoid.configuration
		
		onCurrencyChanged: {
			bitcoinTimer.restart();
		}
		onSourceChanged: {
			bitcoinTimer.restart();
		}
		onRefreshRateChanged: {
			bitcoinTimer.restart();
		}
	}
	
	Timer {
		id: bitcoinTimer
		interval: plasmoid.configuration.refreshRate * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			root.updatingRate = true;
			
			var result = Bitcoin.getRate(plasmoid.configuration.source, plasmoid.configuration.currency, function(rate) {
				root.bitcoinRate = Number(rate).toLocaleCurrencyString(Qt.locale(), Bitcoin.currencySymbols[plasmoid.configuration.currency]);
				
				var toolTipSubText = '<b>' + root.bitcoinRate + '</b>';
				toolTipSubText += '<br />';
				toolTipSubText += i18n('Market:') + ' ' + plasmoid.configuration.source;
				
				plasmoid.toolTipSubText = toolTipSubText;
				
				root.updatingRate = false;
			});
		}
	}
	
	function action_refresh() {
		bitcoinTimer.restart();
	}
	
	function action_website() {
		Qt.openUrlExternally(Bitcoin.getSourceByName(plasmoid.configuration.source).homepage);
	}
}
