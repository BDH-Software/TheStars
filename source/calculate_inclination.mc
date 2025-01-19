//Heavily based on Tim Zander's Slope-Widget (CalculateInclinations.mc):
//https://github.com/TimZander/slope-widget
//https://github.com/TimZander/slope-widget/blob/master/CalculateInclinations.mc
//Apache License
//

import Toybox.Application;
import Toybox.System;
import Toybox.Sensor;
import Toybox.Math;
var save_incl = null;
var ciH_ret = 10;

    //pitch = rotation about watch 9-3 axis, ie, rotating forearm
    //roll = rotation about wathc 12-6 axis, ie, moving forearm up-down from elbow or shoulder
    //inclination= overall slope of watchface, combination of pitch & roll towards "up" and "down" wherever that happens to be oriented on the watch right now
    
    //RETURNS [inclination, pitch, roll]
    //or NULL if not data (or test data if DEBUG==true)
    function calculateInclinationHeading(DEBUG) {
        //var DEBUG=false;
        var pitch, roll, inclination;
        var xAccel, yAccel, zAccel;

        var noData;
        
        var sensorInfo = Sensor.getInfo();
        
        if (sensorInfo has :accel && sensorInfo.accel != null) {
            noData = false;
            var accel = sensorInfo.accel;
            xAccel = accel[0];
            yAccel = accel[1];
            zAccel = accel[2];
            save_incl = [xAccel,yAccel,zAccel ];
        }  else if (save_incl != null) {
            noData = false;
            xAccel = save_incl[0];
            yAccel = save_incl[1];
            zAccel = save_incl[2];
        }
        else{
            noData = true;
            //test inputs
            xAccel = 421;
            yAccel = 1007;
            zAccel = 3405;
        }
        var pitchRad = Math.atan2(yAccel, Math.sqrt(Math.pow(xAccel, 2) + Math.pow(zAccel, 2)));
        var rollRad = Math.atan2(-xAccel, zAccel);
        var inclinationRad = Math.atan(Math.sqrt(Math.pow(Math.tan(pitchRad), 2) + Math.pow(Math.tan(rollRad), 2)));
        pitch = normalize180(Math.toDegrees(pitchRad));
        roll = normalize180(Math.toDegrees(rollRad));
        
        inclination = normalize180(Math.toDegrees(inclinationRad));
        deBug("inclination", [inclination, pitch, roll, ciH_ret]);
        if (!DEBUG && noData) { return null;}
        //if (DEBUG && noData) { return [Math.rand()%180-90, Math.rand()%180-90, Math.rand()%180-90]; }
        ciH_ret +=2;
        ciH_ret = ciH_ret%90;
        if (DEBUG && noData) { return [ciH_ret, Math.rand()%180-90, Math.rand()%180-90]; }
        return [inclination, pitch, roll];
    }


