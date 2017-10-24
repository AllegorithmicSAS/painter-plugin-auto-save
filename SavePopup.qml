// Copyright (C) 2017 Allegorithmic
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

import QtQuick 2.7
import QtQuick.Layouts 1.3
import AlgWidgets 1.0

AlgWindow {
  id: popup
  flags: Qt.Window
          | Qt.MSWindowsFixedSizeDialogHint
          | Qt.CustomizeWindowHint
          | Qt.WindowTitleHint
  modality: Qt.ApplicationModal
  title: "Saving..."
  width: 200
  height: contentLayout.height + 2 * internal.layoutMargins

  QtObject {
    id: internal
    readonly property int layoutMargins: 8
  }

  // overload close method
  function close() {
    // do nothing, the window is not supposed to be closed
  }

  ColumnLayout {
    id: contentLayout
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.margins: internal.layoutMargins
    spacing: 6

    AlgLabel {
      text: "Saving..."
    }
    AlgProgressBar {
      indeterminate: true
      Layout.fillWidth: true
    }
  }
}
