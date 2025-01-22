//Heavily based on Tim Zander's Slope-Widget (CalculateInclinations.mc):
//https://github.com/TimZander/slope-widget
//https://github.com/TimZander/slope-widget/blob/master/CalculateInclinations.mc
//Apache License
//

import Toybox.Application;
import Toybox.System;
import Toybox.Sensor;
import Toybox.Math;
import Toybox.Graphics;
var save_incl = null;
var ciH_ret = 10;

    //pitch = rotation about watch 9-3 axis, ie, rotating forearm
    //roll = rotation about wathc 12-6 axis, ie, moving forearm up-down from elbow or shoulder
    //inclination= overall slope of watchface, combination of pitch & roll towards "up" and "down" wherever that happens to be oriented on the watch right now
    
    //RETURNS [inclination, pitch, roll]
    //or NULL if not data (or test data if DEBUG==true)
    function calculateInclinationHeading(DEBUG, dc) {
        //var DEBUG=false;
        //var pitch, roll, inclination;
        //var pitch;
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
            yAccel = Math.rand()%100-50;
            xAccel = Math.rand()%1500-1000;
            zAccel = Math.rand()%1500-1000;
        }
        //Axes: If watch is flat, face up, X is left-right (9oclock->3oclock positive direction), Y is forward-backward (6oclock-12oclock positive direction), Z is up-down (up positive direction)
        //No in absence of movement, accel will measure the gravitation vector, which is pointing straight down, so negative Z.  Unit is millig, so 1000g = earth gravity.  Since it is pointing down, with the watch face up, the Z component is  -1000 millig.
        //For this project we want to use pitch so you aim the watch by imagining
        //and arrow from 6oclock to 12oclock and aim that at the spot you 
        //want to view. So Pitch (rotation about the X axis) is the rotation angle we want for elevation.
        //tan theta = y/z, but then let's correct for the fact the gravity points
        //down but we want our elevation angle to be 0 when level and to to positive 90 at the zenith, then on the 180 at the opposite horizon.
        //Thus -y/-z.
        //var pitch_rad = Math.atan2(-yAccel, -zAccel); //this is rotation about the X axis, so pitch.  But like an airplane, relative to the XYZ of the device, not the earth, actual horizon, etc.

        //var roll_rad  = Math.atan2 (-xAccel, -zAccel);

        //inclination is the overall slope of the watch face, highest point of the watch face to lowest point, and the angle that makes with the verticle.
        //This formula might needs some signs changed etc depending on the orientation you want ot consider "up" or level/0.
        //var inclination_rad = Math.atan2 (zAccel, Math.sqrt(xAccel*xAccel + yAccel*yAccel));

        //var Y_toVertical_deg= normalize180(Math.toDegrees(pitch_rad));
        //var X_toVertical_deg = normalize180(Math.toDegrees(roll_rad));
        
        //var inclination_deg = normalize180(Math.toDegrees(inclination_rad));

        //deBug("PITCH", [inclination_deg, Y_toVertical_deg, X_toVertical_deg]);


        
        var Y_toVertical_rad = Math.PI - Math.atan2(-yAccel, -Math.sqrt(xAccel*xAccel + zAccel*zAccel));
        if (zAccel > 0) {Y_toVertical_rad = (Math.PI - Y_toVertical_rad);}

        //var Y_toVertical2_rad =Math.asin(yAccel/Math.sqrt(xAccel*xAccel + zAccel*zAccel + yAccel*yAccel));  //This will work but needs some adjustment to convert to Decl degrees.  Gives same answer as atan2 method


        //var rollRad = Math.atan2(-xAccel, zAccel);
        var X_toVertical_rad =   Math.atan2(Math.sqrt(yAccel*yAccel + zAccel*zAccel), xAccel) - Math.PI/2.0;
        if (zAccel > 0) {X_toVertical_rad = (Math.PI - X_toVertical_rad);}
  
        //var inclinationRad = Math.atan(-Math.sqrt(Math.pow(Math.tan(Y_toVertical_rad), 2) + Math.pow(Math.tan(X_toVertical_rad), 2)));

         var Z_toVertical_rad = -Math.atan2(-zAccel, -Math.sqrt(xAccel*xAccel + yAccel*yAccel));
        if (yAccel > 0 || yAccel > 0 ) {Z_toVertical_rad = (Math.PI - Z_toVertical_rad);}


   
        
        var Y_toVertical_deg= normalize180(Math.toDegrees(Y_toVertical_rad));
        //var Y_toVertical2_deg= normalize180(Math.toDegrees(Y_toVertical2_rad));
        var X_toVertical_deg = normalize180(Math.toDegrees(X_toVertical_rad));
        var Z_toVertical_deg= normalize180(Math.toDegrees(Z_toVertical_rad));
        
        //var inclination_deg = normalize180(Math.toDegrees(inclinationRad));


        deBug("Accel", [xAccel, yAccel,  zAccel]); 
        deBug("PITCH", [X_toVertical_deg, Y_toVertical_deg, Z_toVertical_deg, ]);

 
        /*        
        if (dc != null) {
            
            var xc = dc.getWidth() / 2;
            var yc = dc.getHeight() / 2;
            //var font = Graphics.FONT_SYSTEM_LARGE;
            var font = Graphics.FONT_SYSTEM_MEDIUM;
            var textHeight = dc.getFontHeight(font);

            var  txt1 = inclination_deg.format("%.0f") + " " + Y_toVertical_deg.format("%.0f") + " " + X_toVertical_deg.format("%.0f");

                    dc.drawText(
                        xc, 
                        yc - 1*textHeight,
                        font, 
                        txt1, 
                        Graphics.TEXT_JUSTIFY_CENTER
                    );

            /*
            var xAngle = Math.toDegrees(Math.atan2( xAccel, (Math.sqrt(yAccel*yAccel + zAccel*zAccel))));
            var yAngle = Math.toDegrees(Math.atan2( yAccel , (Math.sqrt(xAccel*xAccel + zAccel*zAccel))));
            var zAngle = Math.toDegrees(Math.atan2( Math.sqrt(xAccel*xAccel + yAccel*yAccel), zAccel));

            var  txt2 = xAngle.format("%.0f") + " " + yAngle.format("%.0f") + " " + zAngle.format("%.0f");

            dc.drawText(
                        xc, 
                        yc - 0*textHeight,
                        font, 
                        txt2, 
                        Graphics.TEXT_JUSTIFY_CENTER
            );
            */
            /*
            var txt3 = Y_toVertical_deg.format("%.0f") + " " + xAccel.format("%.0f") + " " + yAccel.format("%.0f") + " " + zAccel.format("%.0f");

            dc.drawText(
                        xc, 
                        yc + 1*textHeight,
                        font, 
                        txt3, 
                        Graphics.TEXT_JUSTIFY_CENTER
            );
        

                //deBug("inclination", [inclination, pitch, roll, xAngle, yAngle, zAngle, ciH_ret]);
            deBug("ipr xyz", [txt1, txt3]);
        }
        */
        
        

        //if (DEBUG) { return [0,6,0];}
        if (!DEBUG && noData) { return null;}
        //if (DEBUG && noData) { return [Math.rand()%180-90, Math.rand()%180-90, Math.rand()%180-90]; }
        //ciH_ret +=2;
        //ciH_ret = ciH_ret%180;
        //if (DEBUG && noData) { return [ciH_ret, Math.rand()%180-90, Math.rand()%180-90]; }
        return [ Y_toVertical_deg, X_toVertical_deg, Z_toVertical_deg]; //the order they are listed in the MENU OPTION for COMPASSPOINT
        //return [ Y_toVertical_deg, X_toVertical_deg, Y_toVertical_deg - 90]; //the order they are listed in the MENU OPTION for COMPASSPOINT
        //return [pitch];
    }


