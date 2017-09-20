// Copyright (C) 2017 Allegorithmic
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

import QtQuick 2.7
import QtQuick.Layouts 1.3
import AlgWidgets 1.0
import AlgWidgets.Style 1.0

Rectangle {
  id: root
  width: 110
  height: 30
  color: "transparent"
  property bool saving: false
  property int remainingWarningTime: 0
  property int remainingTime: 0
  property alias progressMaxValue: progressBar.to
  property bool active: true

  signal clicked()

  ColumnLayout {
    spacing: 0
    anchors.fill: parent
    anchors.margins: 0

    AlgToolButton {
      id: button
      antialiasing: true
      hoverEnabled: true
      enabled: progressBar.value !== progressBar.from && active
      text: saving ? "Saving..." : "Snooze autosave"

      onClicked: root.clicked()
      Layout.fillWidth: true
      Layout.preferredHeight: 24
    }
    AlgProgressBar {
      id: progressBar
      from: 0
      to: 1
      value: remainingTime === 0 && active ? remainingWarningTime : 0
      indeterminate: false
      Layout.fillWidth: true
      Layout.fillHeight: true

      property bool warningState: false
      color: warningState ? AlgStyle.text.color.error : AlgStyle.background.color.highlight.normal

      onValueChanged: {
        if (!timer.running && value <= to * 30 / 100) {
          timer.start()
        }
        else if (value === 0) {
          timer.stop()
          warningState = false;
        }
      }

      Timer {
        id: timer
        repeat: true
        interval: 250
        onTriggered: progressBar.warningState = !progressBar.warningState
      }
    }
  }
}
