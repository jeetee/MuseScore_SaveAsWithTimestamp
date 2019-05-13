import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import Qt.labs.folderlistmodel 2.1
import Qt.labs.settings 1.0

import MuseScore 3.0


MuseScore {
	menuPath: "Plugins.Save with Timestamp"
	description: "Save the score as mscz to the chosen directory using workTitle_Timestamp as filename\nTimestamp is in the format YYYYMMDD-HHMMSS"
	version: "1.0"
	pluginType: "dialog"
	requiresScore: true

	width:  360
	height: 80

	onRun: {
		directorySelectDialog.folder = ((Qt.platform.os == "windows")? "file:///" : "file://") + exportDirectory.text;
	}

	Component.onDestruction: {
		settings.exportDirectory = exportDirectory.text
	}

	Settings {
		id: settings
		category: "SaveAsWithTimestamp"
		property alias exportDirectory: exportDirectory.text
	}

	FileDialog {
		id: directorySelectDialog
		title: qsTranslate("MS::PathListDialog", "Choose a directory")
		selectFolder: true
		visible: false
		onAccepted: {
			exportDirectory.text = this.folder.toString().replace("file://", "").replace(/^\/(.:\/)(.*)$/, "$1$2");
		}
		Component.onCompleted: visible = false
	}

	GridLayout {
		columns: 2
		anchors.fill: parent
		anchors.margins: 10

		Button {
			id: selectDirectory
			text: qsTranslate("PrefsDialogBase", "Browse...")
			onClicked: {
				directorySelectDialog.open();
			}
		}
		Label {
			id: exportDirectory
			text: ""
		}

		Button {
			id: exportButton
			Layout.columnSpan: 2
			text: qsTranslate("PrefsDialogBase", "Export")
			onClicked: {
				var newFileName = curScore.metaTag("workTitle");
				newFileName = newFileName.replace(/ /g, "_");
				newFileName = exportDirectory.text + "//" + newFileName + ".txt";
				var timestamp = (new Date()).toISOString(); //format ISO 8601 YYYY-MM-DDTHH:MM:SS.mmmZ
				var timestampFilter = /(\d+)\-(\d+)\-(\d+)T(\d+):(\d+):(\d+)\.\d+Z/;
				var timestampReformat = '$1$2$3-$4$5$6';
				newFileName += '_' + timestamp.replace(timestampFilter, timestampReformat);
				writeScore(curScore, newFileName, 'mscz');
				Qt.quit();
			}
		}
	}
}
