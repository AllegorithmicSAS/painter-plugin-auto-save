// Copyright (C) 2017 Allegorithmic
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

import QtQuick 2.3
import QtQml 2.2
import QtQml.Models 2.2
import QtQuick.Layouts 1.3
import AlgWidgets 1.0

AlgDialog
{
  id: root;
  visible: false;
  title: "Autosave configuration";
  width: 300;
  height: 150;
  minimumWidth: width;
  minimumHeight: height;
  maximumWidth: width;
  maximumHeight: height;

  signal configurationChanged(int interval, int filesNumber, int snooze, int warningTime)

  Component.onCompleted: {
    internal.initModel()
    internal.emit()
  }

  QtObject {
    id: internal
    readonly property string intervalKey:         "autosaveInterval"
    readonly property string filesNumberKey:      "autosaveNumber"
    readonly property string snoozeKey:           "snooze"
    readonly property string warningTimeKey:      "warningTime"
    readonly property int intervalDefault:        30
    readonly property int filesNumberDefault:     5
    readonly property int snoozeDefault:          30
    readonly property int warningTimeDefault:     10
    readonly property int intervalMax:            100
    readonly property int filesNumberMax:         100
    readonly property int snoozeMax:              100
    readonly property int warningTimeMax:         100

    function newModelComponent(label, min_value, max_value, default_value, settings_name) {
      return {
        "label": label,
        "min_value": min_value,
        "max_value": max_value,
        "default_value": default_value,
        "settings_name": settings_name
      }
    }

    function initModel() {
      model.append(
        newModelComponent(
          "Autosave interval in minutes:",
          1,
          intervalMax,
          intervalDefault,
          intervalKey))
      model.append(
        newModelComponent(
          "Number of autosave files:",
          1,
          filesNumberMax,
          filesNumberDefault,
          filesNumberKey))
      model.append(
        newModelComponent(
          "Snooze interval in seconds:",
          1,
          snoozeMax,
          snoozeDefault,
          snoozeKey))
      model.append(
        newModelComponent(
          "Warning time before save in seconds:",
          1,
          warningTimeMax,
          warningTimeDefault,
          warningTimeKey))
    }

    function getConfiguration() {
      return [
        alg.settings.value(intervalKey, intervalDefault),
        alg.settings.value(filesNumberKey, filesNumberDefault),
        alg.settings.value(snoozeKey, snoozeDefault),
        alg.settings.value(warningTimeKey, warningTimeDefault)
      ]
    }

    function emit() {
      var config = internal.getConfiguration()
      configurationChanged(config[0], config[1], config[2], config[3])
    }
  }

  AlgScrollView {
    id: scrollView;
    parent: root.contentItem
    anchors.fill: parent
    anchors.margins: 4

    ColumnLayout {
      Layout.preferredWidth: scrollView.viewportWidth
      spacing: 12

      Repeater {
        id: layoutInstantiator

        model: ListModel {
          id: model
        }

        delegate: AlgSlider {
          id: slider
          text: label
          minValue: min_value
          maxValue: max_value
          value: alg.settings.value(settings_name, default_value)
          // integers only
          stepSize: 1
          precision: 0
          Layout.fillWidth: true

          Connections {
            target: root
            onAccepted: {
              alg.settings.setValue(settings_name, value);
              internal.emit()
            }
          }
        }
      }
    }
  }
}
