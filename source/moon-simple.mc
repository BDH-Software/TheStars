/***************************************************************************************
* SIMPLIFIED Small & Fast Moon Position & Phase Calculator
*
***************************************************************************************/

//The average duration in modern times is 29.53059 days with up to seven hours variation about the mean in any given year.[7] (which gives a mean synodic month as 29.53059 days or 29 d 12 h 44 min 3 s)[a] A more precise figure of the average duration may be derived for a specific date using the lunar theory of Chapront-Touzé and Chapront (1988):
//29.5305888531 + 0.00000021621T − 3.64×10−10T2 where T = (JD − 2451545.0)/36525 and JD is the Julian day number (and JD = 2451545 corresponds to 1 January AD 2000 at Noon.)
//Source: https://en.wikipedia.org/wiki/Lunar_month#Synodic_month
//
//This is an approximation and any phase/full moon may be off by as much as +/- 7 hours. The moon moves about 0.5 degrees per hour against the background stars, so the difference may be about +/- 3.5 degrees visually or +/- 12 minutes.  This is large enough to be seen visually on i.e. even a small
//24-hour clock dial but considering we are only showing a approx. sky positions & rough moon quarter this probably good enough for many applications.

import Toybox.Math;
import Toybox.System;
import Toybox.Lang; 

class simpleMoon {
   /*
    //  can use Time.Gregorian.info() output for now_info &
    // now = System.getClockTime(); output for now.timeZoneOffset and now.dst
    //Note timeZoneOffset_sec is SECONDS not hours
    public function synodicMonthLength_days(now_info, timeZoneOffset_sec, dst ) {
        if (timeZoneOffset_sec == null) {timeZoneOffset_sec = 0;}
        if (dst == null) {dst = 0;}


        var JD = julianDate (now_info.year, now_info.month, now_info.day, now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);

        var T = (JD - 2451545.0d)/36525d;

        return 29.5305888531d + 0.00000021621d* T - 3.64E-10d * T*T;
    }

    //Using above month length, you can calculate new moon etc starting with any
    //known new moon date/time
    //We will use: 2025 Jan 29  12:36 UTC
    // JD = 2460705 ; 2460705.025000
    //This will return the current % of lunar phase as a number ranging 0 to 1
    // 0 & 1 are new moon, 0.5 full moon, etc.
    //returns a triplet: [lunar phase(0-1), current lunar day, synodic month length in days]

    public function lunarPhase (now_info, timeZoneOffset_sec, dst) {

        var sml_days  = synodicMonthLength_days(now_info, timeZoneOffset_sec, dst );
        var base_JD = julianDate (2025, 1, 29 , 12, 36, 0, 0);
        var current_JD = julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);

        var difference = current_JD - base_JD;

        var lunar_day = mod (difference, sml_days);

        var lunar_phase = lunar_day/sml_days;

        return [lunar_phase, lunar_day, sml_days];

    }
    */

    public function eclipticPos (now_info, timeZoneOffset_sec, dst,  addTime_hrs) {

        //var sml_days  = synodicMonthLength_days(now_info, timeZoneOffset_sec, dst );
        //var base_JD = julianDate (2025, 1, 29 , 12, 36, 0, 0);
        var current_JD = julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, timeZoneOffset_sec/3600, dst);
        current_JD += addTime_hrs/24.0d;
        return getGeocentricMoonPos(current_JD);
    }

    // Low Precision Moon Position
    //Accurate to .5 deg over period 1900-2100
    // Source
    // https://celestialprogramming.com/lowprecisionmoonposition.html
    //Input: Julian Date
    //Output: Ecliptical Long, Lat 
    // (rem-ed out portion converts this to geocentric RA & Decl)

    function getGeocentricMoonPos(jd){
	var T = (jd-2451545)/36525;
	var L = 218.32 + 481267.881*T + 6.29*sind(135.0 + 477198.87*T) - 1.27*sind(259.3 - 413335.36*T) + 0.66*sind(235.7 + 890534.22*T) + 0.21*sind(269.9 + 954397.74*T) - 0.19*sind(357.5 + 35999.05*T) - 0.11*sind(186.5 + 966404.03*T);
	var B = 5.13*sind( 93.3 + 483202.02*T) + 0.28*sind(228.2 + 960400.89*T) - 0.28*sind(318.3 + 6003.15*T) - 0.17*sind(217.6 - 407332.21*T);
	//var P = 0.9508 + 0.0518*cosd(135.0 + 477198.87*T) + 0.0095*cosd(259.3 - 413335.36*T) + 0.0078*cosd(235.7 + 890534.22*T) + 0.0028*cosd(269.9 + 954397.74*T);
    return [normalize(L),normalize(B)];

    /*
    //convert to geocentric ra & decl
	var SD=0.2724*P;
	var r=1/sind(P);

	var l = cosd(B) * cosd(L);
	var m = 0.9175*cosd(B)*sind(L) - 0.3978*sind(B);
	var n = 0.3978*cosd(B)*sind(L) + 0.9175*sind(B);

	var ra=Math.atan2(m,l);
	if(ra<0){ra+=2*Math.PI;}
	var dec=Math.asin(n);
	return [ra,dec];
    */
    }


}
