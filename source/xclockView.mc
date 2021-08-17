using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math; 
using Toybox.UserProfile as Profile;

var highPower = false;
var PowerModeSwitched = false;

var diameter;
var radius;
var cn = 0.0;

var s = 0.0;
var	c = 0.0;
var	wc = 0.0;
var	ws = 0.0;
var width = 0.0;

var hourHandLength;
var	minHandLength;

var minutes;
var minutesOld = -1;

var	time;
var timeOld;

var sleepTime;
var wakeTime;
var sleeping = false;

const BATTERY_SIZE_LARGE = [55, 29];
const BOX_PADDING = 2;
const TEXT_PADDING = [1, 2];
	
function max(a, b) {
    if(a > b) {
        return a;
    } else {
        return b;
    }
}

function min(a, b) {
    if(a < b) {
        return a;
    } else {
        return b;
    }
}

function round(x) {
    if(x >= 0) {
        return Math.floor(x + 0.5);
    } else {
        return Math.floor(x - 0.5);
    }
}

class xclockView extends WatchUi.WatchFace {

    var MARGIN_FACTOR = 0.97;
    var ORIGINAL_SIZE = 116.0; //width of the face on vivoactive3 with mul=1
    var TICK_FRACT = 95;
    var MINOR_TICK_FRACT = 90;
    var HAND_WIDTH = 7;
    var HOUR_HAND_LENGTH = 40;
    var MINUTE_HAND_LENGTH = 70;

	function drawTicks(dc) { 
	    for(var i = 0; i < 60; i++) {
           var x1 = Math.sin(Math.toRadians(i*6));
           var y1 = Math.cos(Math.toRadians(i*6));
           var frac;
           if(i % 5) {
               frac = TICK_FRACT;
           } else {
               frac = MINOR_TICK_FRACT;
           }
       	   var x2 = x1 * (frac / 100.0);
       	   var y2 = y1 * (frac / 100.0);
           var mul = MARGIN_FACTOR/(ORIGINAL_SIZE/diameter);
       	   dc.drawLine((mul*Math.toDegrees(x1))+radius, (mul*Math.toDegrees(y1))+radius, 
               (mul*Math.toDegrees(x2))+radius, (mul*Math.toDegrees(y2))+radius);
        }
	}

    function initialize() {
        WatchFace.initialize();
    }
        
         
    // Load your resources here 
    function onLayout(dc) { //baswi, function inserted
    	if (!highPower) {
			setLayout(Rez.Layouts.WatchFace(dc));
			
        	diameter = max(dc.getHeight(), dc.getWidth());
        	radius = diameter/2;
			$.width = (HAND_WIDTH*radius)/100;
			$.cn = [dc.getWidth()/2, dc.getHeight()/2];
			$.hourHandLength = (HOUR_HAND_LENGTH*radius)/100.0;
			$.minHandLength = (MINUTE_HAND_LENGTH*radius)/100.0;

        	$.timeOld = System.getClockTime(); //init time var
        
        	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        	dc.clear(); //does not seem to work HERE
    	    dc.setPenWidth(1);
	        drawTicks(dc); //baswi inserted; only draw ticks once
			sleepTime = Profile.getProfile().sleepTime;
			wakeTime = Profile.getProfile().wakeTime;
	        
		} else {
			setLayout(Rez.Layouts.WatchFaceAlt(dc));
		}
    
    }

	//! The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() {
		if (!sleeping) { //do not activate highPower if user is sleeping
			highPower = true;
			PowerModeSwitched = true;
		}
	}

	//! Terminate any active timers and prepare for slow updates.
	function onEnterSleep() {
		highPower = false;
		PowerModeSwitched = true;

		//Force update
		WatchUi.requestUpdate();
	}

    function onUpdate(dc) {
		var now = Time.now();
		var today = Time.today();

		//var hours = sleepTime.divide( 3600 ).value();
		//var minutes = sleepTime.value() - ( hours * 3600 );
		//var seconds = sleepTime.value() - ( hours * 3600 ) - ( minutes * 60 );
		//var string = "Wake Time: " + hours.format("%02u") + ":" + minutes.format("%02u") + ":" + seconds.format("%02u");
		//System.println(string);
		
		var nowAbs = now.value();
		var nowDays = (nowAbs / (24*3600));
		//System.println("nowAbs" + nowAbs);
		//System.println("nowDays" + nowDays);
		//System.println("sleepTime" + sleepTime.value());
		//System.println("wakeTime" + wakeTime.value());
		//NB; logical OR is needed if condition below; otherwise after 
		//    midnight nowAbs < (nowDays*24*3600 + sleepTime), because number of days increased
		if ((nowAbs > (nowDays*24*3600 + sleepTime.value())) ||
			(nowAbs < (nowDays*24*3600 + wakeTime.value()))
		   ) {
			sleeping = true; //current time is in sleeping times of user
		} else {
			sleeping = false;
		}
		

	//	if (now.greaterThan(today.add(sleepTime)) && now.lessThan(today.add(wakeTime))) {
	//		System.println("sleeping"+sleepTime+wakeTime);
	//	} else {
	//		System.println("awake"+sleepTime+wakeTime); 
	//	} 
    
 	   	if (highPower) {
 	   		if (PowerModeSwitched) {
 	   			PowerModeSwitched = false;
				onLayout(dc);
			}
			// Get and show the current time
			var clockTime = System.getClockTime();
			var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
			var view = View.findDrawableById("TimeLabel");
			view.setText(timeString);
			// Call the parent onUpdate function to redraw the layout
			View.onUpdate(dc); //only necessary after switchin layout
        } else { //low power mode
	        $.time = System.getClockTime();
    	    $.minutes = $.time.min;
			if ((!sleeping) || (($.minutes % 5) == 0)) { //update every 5 min, if user sleeps                  
 				if (PowerModeSwitched) { //switched from high to low power mode
	        		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        	    	dc.clear();
        	    	drawTicks(dc); //baswi inserted; only draw ticks once
 				}
            	//if minutes changed, or switched to low power
        		if (($.minutesOld != $.minutes) || PowerModeSwitched) {
        			PowerModeSwitched = false;
	        		drawFace(dc);
	        		drawBatteryBox(dc, 115, 30);
	        		$.minutesOld = $.minutes; //save when watch was updated
	    		}
	    	}
        }        
    }

    function drawFace(dc) {
		//clear previous hands
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);	
        drawHand(dc, (timeOld.hour%12)*30 + timeOld.min/2, $.width, $.hourHandLength);
        drawHand(dc, timeOld.min*6, $.width, $.minHandLength);

		$.timeOld = $.time;			
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);	
        drawHand(dc, ($.time.hour%12)*30 + $.time.min/2, $.width, (HOUR_HAND_LENGTH*$.radius)/100.0);
        drawHand(dc, $.time.min*6, $.width, (MINUTE_HAND_LENGTH*$.radius)/100.0);
    }
    
	function drawHand(dc, angle, w, l) {
        var s = Math.sin(Math.toRadians(angle));
        var c = Math.cos(Math.toRadians(angle));
        var wc = w*c;
        var ws = w*s;
        dc.fillPolygon([
            [cn[0] + round(l*s), cn[1] - round(l*c)],
            [cn[0] - round(ws+wc), cn[1] + round(wc-ws)],
            [cn[0] - round(ws-wc), cn[1] + round(wc+ws)],
        ]);
    }
    
	function drawTextBox(dc, text, x, y, boxWidth, boxHeight) {
		dc.setPenWidth(2);
		
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
		dc.fillRectangle(x, y, boxWidth, boxHeight); //erase current rectangle
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);		        
		
		dc.drawRoundedRectangle(x, y, boxWidth, boxHeight, BOX_PADDING);

		var boxText = new WatchUi.Text({
			:text=>text,
			:color=>Graphics.COLOR_BLACK,
			:font=> Graphics.FONT_SYSTEM_TINY,
			:locX =>x,
			:locY=>y,
			:justification=>Graphics.TEXT_JUSTIFY_LEFT
		});

		boxText.draw(dc);
	}
	
    function drawBatteryBox(dc, x, y) {
			var battery = System.getSystemStats().battery;
			var batteryString = battery.format("%.1f");

			batteryString = " " + batteryString;
			drawTextBox(dc, batteryString, x, y, BATTERY_SIZE_LARGE[0], BATTERY_SIZE_LARGE[1]);
		}
}
