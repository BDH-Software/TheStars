//Heavily based on Tim Zander's Slope-Widget (CalculateInclinations.mc):
//https://github.com/TimZander/slope-widget
//https://github.com/TimZander/slope-widget/blob/master/CalculateInclinations.mc
//Apache License
//

import Toybox.Application;
import Toybox.System;
import Toybox.Sensor;
import Toybox.Math;

    //pitch = rotation about watch 9-3 axis, ie, rotating forearm
    //roll = rotation about wathc 12-6 axis, ie, moving forearm up-down from elbow or shoulder
    //inclination= overall slope of watchface, combination of pitch & roll towards "up" and "down" wherever that happens to be oriented on the watch right now
    
    //RETURNS [inclination, pitch, roll]
    //or NULL if not data (or test data if DEBUG==true)
    function calculateInclinationHeading() {
        var DEBUG=false;
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
        if (!DEBUG && noData) { return null;}
        return [inclination, pitch, roll];
    }


