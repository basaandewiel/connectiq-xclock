using Toybox.Application;
using Toybox.WatchUi as Ui;

//class xclockApp extends Ui.WatchFace {
class xclockApp extends Application.AppBase {
 
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }
    
    function onSettingsChanged() { // triggered by settings change in GCM
	}
	


    function getInitialView() {
        return [ new xclockView() ];
    }
}
