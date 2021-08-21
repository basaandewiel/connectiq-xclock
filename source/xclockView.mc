using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math; 
using Toybox.UserProfile as Profile;
using Toybox.Time;


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

    var HAND_WIDTH = 7;
    var HOUR_HAND_LENGTH = 40;
    var MINUTE_HAND_LENGTH = 70;


    function initialize() {
        WatchFace.initialize();
    }
        
         
    // Load your resources here 
    function onLayout(dc) { //baswi, function inserted
    	//NB: You should only do drawing from onUpdate(), NOT here
		sleepTime = Profile.getProfile().sleepTime;
		wakeTime = Profile.getProfile().wakeTime;	
		$.time = System.getClockTime(); //must be initialised before onupdate is called
		        

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
        	dc.setPenWidth(1);
		} else {
			//baswi:onlayout is NOT called when high power mode is entered
		}
	    View.onUpdate(dc);
    }

	//! The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() {
		System.println("onExitSleep");
		if (!sleeping) { //do not activate highPower if user is sleeping
			highPower = true;
			PowerModeSwitched = true;
			System.println("switched to HIGH power");
			
			//Force update
			WatchUi.requestUpdate();
		}
	}

	//! Terminate any active timers and prepare for slow updates.
	function onEnterSleep() {
		highPower = false;
		PowerModeSwitched = true;
		System.println("switched to LOW power");

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
 	   			System.println("switched to HIGH power");
 	   			System.println("set WatchFaceALT");
				setLayout(Rez.Layouts.WatchFaceAlt(dc));
			}
			// Get and show the current time
			var clockTime = System.getClockTime();
			var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);

	        var timelabel = View.findDrawableById("TimeLabel");


   			var dateString;
   			var dateFormat = "$1$ $2$";
   			var timeFormat = "$1$:$2$";
   			var localTimeInfo = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
			 		            
        	dateString = Lang.format(dateFormat, [localTimeInfo.day_of_week.toUpper(), localTimeInfo.day.format("%02d")]);
        	var dateLabel = View.findDrawableById("DateLabel");
        	dateLabel.setText(dateString);


    	    //var fnt = WatchUi.loadResource(Rez.Fonts.Numbers);
        	//view.setFont(fnt);
        	//view.setColor(Application.getApp().getProperty("ForegroundColor"));
        	timelabel.setText(timeString);
        	// Call the parent onUpdate function to redraw the layout
    	    View.onUpdate(dc);        				
        } else { //low power mode
	        $.time = System.getClockTime();
    	    $.minutes = $.time.min;
    	    var myBackgroundInst = View.findDrawableById("myBackground");
					
			if ((!sleeping) || (($.minutes % 5) == 0)) { //update every 5 min, if user sleeps                  
 				if (PowerModeSwitched) { //switched from high to low power mode
 					System.println("switched to low power, clear and redraw ticks");
 					System.println("set WatchFace");
					setLayout(Rez.Layouts.WatchFace(dc));
 					
	        		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);		
        	    	
//        	    	drawTicks(dc);
//	        		drawFace(dc);
	        		$.minutesOld = $.minutes; //save when watch was updated
	        		//The View.onUpdate() function's primary job is to clear the screen and draw the items within your layout
	        		//If you're not using layouts you wouldn't necessarily need to call it.
					//Because it will clear the screen. This means if you call it later in your own onUpdate function anything you've already drawn will be wiped out. 
					//It also draws the items in your layout. So the proper way to use it would be:
					//function onUpdate(dc) {
						// Update items in your layout
						// Call parent onUpdate() to clear the screen/draw the updated layout items
						//View.onUpdate(dc);
						// Do any manual drawing here. It will draw on top of the layout.
				}
 					//}
            	//if minutes changed, or switched to low power
        		if (($.minutesOld != $.minutes) || PowerModeSwitched) {
        			PowerModeSwitched = false;
	        		//myBackgroundInst.draw(dc);
	        		//backgroundView.drawFace(dc);
	        		$.minutesOld = $.minutes; //save when watch was updated
	        		
			        // Update fields
        			var dateLabel = View.findDrawableById("DateLabel");
        			var batterylabel = View.findDrawableById("BatteryLabel");

        			var dateString;
        			var dateFormat = "$1$ $2$";
        			var timeFormat = "$1$:$2$";
        			var localTimeInfo = Time.Gregorian.info(now, Time.FORMAT_MEDIUM);
        			var localHour = localTimeInfo.hour;
 		            var localTimeStr = Lang.format(timeFormat, [localHour, localTimeInfo.min.format("%02d")]);
        			dateString = Lang.format(dateFormat, [localTimeInfo.day_of_week.toUpper(), localTimeInfo.day.format("%02d")]);
        			dateLabel.setText(dateString);

					var battery = System.getSystemStats().battery;
					var batteryString = battery.format("%.1f");
					batterylabel.setText(batteryString);
	    		}
	    		//System.println("BEFORE view.onupdate");
        	    View.onUpdate(dc); //NB: clears screen with BLACK background if using layouts, AND draws elements
        	    //present in layout.xml file
        	    //baswi tested: view.onupdate calls draw function of class specified in layout.xml
        	    //System.println("AFTER view.onupdate");
	    	}	    
        }
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

    
	
}
