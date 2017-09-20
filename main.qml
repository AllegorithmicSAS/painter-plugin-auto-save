// Copyright (C) 2017 Allegorithmic
//
// This software may be modified and distributed under the terms
// of the MIT license.  See the LICENSE file for details.

import QtQuick 2.7
import Painter 1.0

PainterPlugin
{
  ConfigurationStruct {
    id: config
  }

  // timer to display the popup since WorkerScript cannot be used
  // with alg context
  Timer
  {
    id: savePostProcess
    repeat: false
    interval: 1
    onTriggered: {
      try {
        alg.log.info("Copying into autosave backup number " + config.actualFileIndex + "...");
        var origPath
        if (alg.project.name() === "Untitled") {
          // use config default
          if (config.tempFileName === "") {
            var date = new Date()
            config.tempFileName = date.toLocaleDateString(Qt.locale(), "dd_MM_yyyy_hh_mm")
          }
          var targetDirectory = alg.fileIO.documentsLocation()
          origPath = targetDirectory + "autosave/" + config.tempFileName + ".spp"
        }
        else origPath = alg.fileIO.urlToLocalFile(alg.project.url());
        // remove extension
        var pathTemplate = origPath.replace(/\.[^\.]*$/, "")
        // remove front slashes
        pathTemplate = pathTemplate.replace(/^\/+/, "")

        alg.project.saveAsCopy("file:///" + pathTemplate + "_autosave_" + config.actualFileIndex + ".spp")

        ++config.actualFileIndex
        // close() is disable for the popup, we must affect visible directly
        savePopup.visible = false
      }
      catch(err) {
        alg.log.exception(err)
        savePopup.visible = false
      }
    }
  }

  QtObject {
    id: internal
    property bool projectOpen: alg.project.isOpen()
    property bool active: projectOpen && !configDialog.visible
    readonly property alias saving: savePopup.visible
    property bool computing: false
    onActiveChanged: {
      if (active) {
        reinitRemainingTime()
        timer.start()
      }
      else timer.stop()
    }

    function incrFileIndex() {
      ++config.actualFileIndex;
      if (config.actualFileIndex >= config.filesNumber) config.actualFileIndex = 0
    }

    function save() {
      if(alg.project.needSaving())
      {
        alg.log.info("Autosaving...");
        savePopup.visible = true
        savePostProcess.start()
      }
    }

    function reinitRemainingTime() {
      config.remainingTime = config.interval
      config.remainingWarningTime = config.warningTime
    }

    function snooze() {
      if (config.remainingTime < config.warningTime) {
        config.remainingTime = config.snooze
        config.remainingWarningTime = config.warningTime
      }
    }
  }

  Timer
  {
    id: timer
    repeat: true
    interval: 1000
    onTriggered: {
      // reinitialize timer if null
      if (config.remainingTime == 0) {
        if (config.remainingWarningTime == 0) {
          internal.reinitRemainingTime()
        }
        else {
          --config.remainingWarningTime
        }
      }

      if (!internal.saving && config.remainingTime != 0) --config.remainingTime;

      if (config.remainingWarningTime == 0) {
        // If computing, wait until computation end
        if (internal.computing) return
        // save
        internal.save();
      }
    }
  }

  Component.onCompleted:
  {
    // save button
    var snoozeButton = alg.ui.addToolBarWidget( "SnoozeButton.qml" )
    // bind remaining time and saving values
    snoozeButton.remainingTime = Qt.binding(function() { return config.remainingTime })
    snoozeButton.remainingWarningTime = Qt.binding(function() { return config.remainingWarningTime })
    snoozeButton.saving = Qt.binding(function() { return internal.saving })
    snoozeButton.progressMaxValue = Qt.binding(function() { return config.warningTime })
    snoozeButton.active = Qt.binding(function() { return internal.active })
    // bind button status
    snoozeButton.clicked.connect(internal.snooze)
  }

  onProjectSaved: internal.reinitRemainingTime()

  onProjectAboutToClose: {
    config.tempFileName = ""
    internal.projectOpen = false
  }

  onProjectOpened: internal.projectOpen = true

  onNewProjectCreated: internal.projectOpen = true

  onComputationStatusChanged: {
    internal.computing = isComputing
  }

  onConfigure:
  {
    configDialog.open();
  }

  ConfigurePanel
  {
    id: configDialog

    onVisibleChanged: {
      if (visible) timer.stop
      else if (internal.active) timer.restart()
    }

    onConfigurationChanged: {
      // interval in minutes
      config.interval = interval * 60
      config.filesNumber = filesNumber
      if (config.actualFileIndex >= filesNumber) config.actualFileIndex = 0
      config.snooze = snooze
      config.warningTime = warningTime
    }
  }

  SavePopup {
    id: savePopup
  }
}
