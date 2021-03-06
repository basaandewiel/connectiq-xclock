using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Math;

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

    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
    	View.onUpdate(dc);
       	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
       	dc.clear();
        drawFace(dc);
    }

    function drawFace(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);	
        dc.setPenWidth(1);
        var diameter = max(dc.getHeight(), dc.getWidth());
        var radius = diameter/2;

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

        var time = System.getClockTime();
        var width = (HAND_WIDTH*radius)/100;
        drawHand(dc, (time.hour%12)*30 + time.min/2, width, (HOUR_HAND_LENGTH*radius)/100.0);
        drawHand(dc, time.min*6, width, (MINUTE_HAND_LENGTH*radius)/100.0);
        //drawHand(dc, time.min*6 + time.sec/10, width, (MINUTE_HAND_LENGTH*radius)/100);
    }

    //dc.fillPolygon([]);
    function drawHand(dc, angle, w, l) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);	
        dc.setPenWidth(1);
        var cn = [dc.getWidth()/2, dc.getHeight()/2];
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
}
