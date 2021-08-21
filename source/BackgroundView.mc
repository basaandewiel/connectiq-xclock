using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Application;
using Toybox.Time.Gregorian as Date;
using Toybox.Time;
using Toybox.Math; 

	var mark_length = 10;

class myBackgroundC extends Ui.Drawable {
    var MARGIN_FACTOR = 0.97;
    var ORIGINAL_SIZE = 116.0; //width of the face on vivoactive3 with mul=1
    var TICK_FRACT = 95;
    var MINOR_TICK_FRACT = 90;


	hidden var bgcir_font, bgcir_info;
	hidden var callback;

	function initialize(params) {
		// You should always call the parent's initializer and
        // in this case you should pass the params along as size
        // and location values may be defined.
        //Workaround for crash - nbr of parameters
		//Define at least one param element inside the drawable definition:
		//<layout id="MainLayout" ...>
		//<drawable id="my_id" class"GraphDrawable">
		//<param name="locX">0</param>
		//<param name="locY">0</param>
		//</drawable>
		//</layout>
		Drawable.initialize(params);  //initialize parrent class	
		callback = params[:callback];
	}


    function draw(dc) {
    	//System.println("CLASS: MyBackgroundC: function:draw");
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
		dc.clear();
		drawTicks(dc);
	    drawFace(dc);
    }
    
    function drawTicks(dc) {
//    	System.println("myBackgroundViewC: drawTicks");
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
	
	
	function drawFace(dc) {
		//clear previous hands
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);	
        drawHand(dc, (timeOld.hour%12)*30 + timeOld.min/2, $.width, $.hourHandLength);
        drawHand(dc, timeOld.min*6, $.width, $.minHandLength);

		$.timeOld = $.time;			
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);	
        drawHand(dc, ($.time.hour%12)*30 + $.time.min/2, $.width, $.hourHandLength);
        drawHand(dc, $.time.min*6, $.width, $.minHandLength);        
    }
    
	
    
}