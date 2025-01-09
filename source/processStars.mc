import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.System;
import Toybox.Math;



//var pp = [{},{},{},{},{}];
//var pp1 = {};
//var pp2 = {};
//var pold = [{},{}];
var cc = {};
//(:hasByteArray)
//var ret as Lang.ByteArray = []b;
/*
(:hasByteArray)
var pp_az as Lang.ByteArray = []b;
(:hasByteArray)
var pp_alt as Lang.ByteArray = []b;
(:hasByteArray)
var pp_mag as Lang.ByteArray = []b;
*/


//(:noByteArray)
//var ret as Lang.ByteArray = [];
//(:noByteArray)
var pp_az as Lang.ByteArray = [];
//(:noByteArray)
var pp_alt as Lang.ByteArray = [];
//(:noByteArray)
var pp_mag as Lang.ByteArray = [];



typedef pp_inConst as Array<Boolean>; //if its in a constellation,
typedef pp_hipp as Array<Number>;
typedef cc_name as Array<String>;
typedef cc_stars as Array<Array<String>>;
typedef temp_PPIndex as Array<Dictionary<Number,Number>>;

var pp_inConst = [];
var pp_hipp = [];
var cc_name = [];
var cc_stars = [];

var temp_PPIndex = [{},{},{},{},{},{},{},{},{},{},{},{},{},]; //same as # of hipparcos thingers
var pp_count as Lang.Number = 0;

var hippconst_finished = false;
var hipp_proc = 0;
var const_proc = 0;
var hipp_finished = false;
var const_finished = false;
var gmst_deg=0;
//var byteConv = 256/360.0;

/*
(:hasByteArray)
function processStars_init(){
    //pp = [{},{},{},{},{}];
    cc = {};
    //ret = [3]b;
    pp_az = []b;
    pp_alt = []b;
    pp_mag = []b;
    pp_hipp = [];    
    cc_name = [];
    cc_stars = [];
    temp_PPIndex = [{},{},{},{},{},{},{},{},{},{},{},{},{},];
    pp_count = 0;

    hippconst_finished = false;
    hipp_proc = 0;
    const_proc = 0;
    hipp_finished = false;
    const_finished = false;
    started = false;

    
    var jd_ut = julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600f, $.now.dst);

    $.gmst_deg = Math.toDegrees(greenwichMeanSiderealTime(jd_ut));

}

(:noByteArray)
*/

function processStars_init(){
    //pp = [{},{},{},{},{}];
    cc = {};
    //ret = [3]b;
    pp_az = [];
    pp_alt = [];
    pp_mag = [];
    pp_hipp = [];    
    cc_name = [];
    cc_stars = [];
    temp_PPIndex = [{},{},{},{},{},{},{},{},{},{},{},{},{},];
    pp_count = 0;

    hippconst_finished = false;
    hipp_proc = 0;
    const_proc = 0;
    hipp_finished = false;
    const_finished = false;
    started = false;

    var jd_ut = julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600f, $.now.dst);

    $.gmst_deg = Math.toDegrees(greenwichMeanSiderealTime(jd_ut));

    //deBug("JDGMST", [jd_ut, $.gmst_deg]);

}

function processStars(){    

    

    var pp_orig = {};

    var pprez = [$.Rez.JsonData.hipparcos4_1,
    $.Rez.JsonData.hipparcos4_2,
    $.Rez.JsonData.hipparcos4_3,
    $.Rez.JsonData.hipparcos4_4,
    $.Rez.JsonData.hipparcos4_5,
    $.Rez.JsonData.hipparcos4_6,
    $.Rez.JsonData.hipparcos4_7,
    $.Rez.JsonData.hipparcos4_8,
    $.Rez.JsonData.hipparcos4_9,
    $.Rez.JsonData.hipparcos4_10,
    $.Rez.JsonData.hipparcos4_11,
    $.Rez.JsonData.hipparcos4_12,
    $.Rez.JsonData.hipparcos4_13,
    
    ];


    //for (var j = 0; j < pprez.size(); j++) {
    var j = hipp_proc;
    if (j < pprez.size()) {

            pp_orig= WatchUi.loadResource( pprez[j]) as Dictionary;

            var myStats = System.getSystemStats();
            System.println("Memory2: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            myStats = null; 
            

            //get rid of any stars that cannot be seen from this latitude (sloppy filter >85 instead aof >90 to reduce size a bit more)
            var kys = pp_orig.keys();
            //deBug("pppor",[pp_orig,kys]);
            var sz = kys.size();
            //var ppsz = sz/5 + 1;
            for (var i =0; i<sz; i++) {
                var star = pp_orig[kys[i]];
                if (normalize180(lastLoc[0] - star[2]).abs()>95) {
                    //pp_orig.remove(kys[i]);
                    //deBug("omit", [kys[i], star]);
                    continue;
                } 

                var res = raDecToAltAz_deg(star[1],star[2],lastLoc[0],lastLoc[1],$.gmst_deg); //remember they are listed in order MAG, RA, DECL

                //deBug("RADEC", [star[1],star[2],lastLoc, $.gmst_deg]);
                //var az = res[0];
                //var alt = res[1];
            
            
                //deBug("alt", [az, alt]);
                if (res[1]<-2) {
                    //deBug("omit2", [kys[i], res, star]);
                    continue;
                }


                //var ret as Lang.ByteArray = [];
                //deBug("256b",[star[1]*256/360, (star[1]*256/360).toChar(), (star[1]*256/360 ) & 256]);
                pp_hipp.add(kys[i].toNumber());
                //pp_az.add((res[0]*256/360).toNumber()); 
                pp_az.add((res[0]).toNumber()); 
                pp_alt.add((res[1]).toNumber());
                pp_mag.add((star[0]).toNumber());

                temp_PPIndex[j].put(kys[i].toNumber(), pp_count);
                //deBug("PP_", [kys[i].toNumber(), star, res[0]*256/360, res[1], star[0], pp_hipp[pp_count], pp_az[pp_count], pp_alt[pp_count], pp_mag[pp_count]] );
                pp_count++;


            }   
            
            kys = null;
            pp_orig = null;
            hipp_proc++;
    }

        
    if (hipp_proc >= pprez.size()) { 
        
        pp_inConst = new Array <Boolean> [pp_hipp.size()];
        
        hipp_finished = true;

    }
        /*
        var keys = $.pp1.keys();
        for (var i = 0; i < keys.size(); i++) {
            var key = keys[i];
            var myStats = System.getSystemStats();
            System.println("Memory2: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            myStats = null;
            deBug("PPPPQ2",[key]);
            pp.put(key,pp1[key]);
        }
        pp1 = null;
        keys = $.pp2.keys();
        for (var i = 0; i < keys.size(); i++) {
            var key = keys[i];
            pp.put(key,pp2[key]);
        }

        pp2 = null;
        keys = null;
    }
    */
    
    pprez = [$.Rez.JsonData.constellations_stellarium_1,
    $.Rez.JsonData.constellations_stellarium_2,
    $.Rez.JsonData.constellations_stellarium_3,
    $.Rez.JsonData.constellations_stellarium_4,
    $.Rez.JsonData.constellations_stellarium_5,
    $.Rez.JsonData.constellations_stellarium_6,
    $.Rez.JsonData.constellations_stellarium_7,
    
    
    ];


            //var myStats = System.getSystemStats();
            //System.println("Memory2: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            //myStats = null;

    j = const_proc;
    if (hipp_finished && j < pprez.size()) {
            //for (var j = 0; j < pprez.size(); j++) { 
                pp_orig = WatchUi.loadResource( pprez[j]) as Dictionary;
                var kys = pp_orig.keys();

                for (var i = 0; i<kys.size(); i++) {
                    var key = kys[i];
                    var cnst = pp_orig[key];
                    var cnstKs = [];
                    var tal = 0;
                    var himag = 10000000;
                    //var saveStar = [];

                    //var saveStar2 = null;
                    for (var k = 0; k<cnst.size();k=k+2) {
                        var star = [];
                        star.add(cnst[k].toNumber());
                        star.add (cnst[k+1].toNumber());
                        var starK = new Array <Number> [2];
                        //if ($.pp.hasKey(star)) {
                        for (var x =0;x<2;x++) {
                            starK[x] = ppReturnKey(star[x]);
                            //deBug("cstll3", [key, cnst, star, starK]);
                            
                            
                            if (starK[x] != null) {
                                tal++;
                                //var mag = pp[starK[0]][starK[1]][0];
                                //deBug("constlll", [starK, k, cnst[k], pp_mag.size() ]);
                                var mag = pp_mag[starK[x]];
                                if (mag < himag) { himag = mag;}                            
                            }                        
                        }

                        if (starK[0] != null && starK[1] != null) {
                                cnstKs.add(starK[0]);                                  
                                cnstKs.add(starK[1]);
                                
                                pp_inConst[starK[0]] = true;
                                pp_inConst[starK[1]] = true;
                        } 

                        //could stitch up any missing stars here, but ....
                        
                        /* else if (starK[0]==null) {
                            saveStar[0] = stark[1]; //the GOOD one first
                            saveStar[1] = starK[0]; //bad one

                        } else if (starK[1]==null) {
                            saveStar[1] = stark[1]; 
                            saveStar[0] = starK[0]; //bad one
                        } else {continue;}

                        if (saveStar!=null &&)
                        */

                    }
                    //if (tal*100/cnst.size()>50 && himag < 45) {
                    //deBug("const444", [key, cnst, tal, himag, cnstKs]);
                    if (tal*100/cnst.size()>5) {
                        //deBug("adding", [key, tal, himag, cnst.size()]);
                        //$.cc.put(key,cnst);
                        cc_name.add(key);
                        cc_stars.add(cnstKs);
                        //deBug("adding", [key, tal, himag, cnst.size()]);
                    } else {
                        //deBug("omitting", [key, tal, himag, cnst.size()]);
                    }
                }

                pp_orig = null;
            //}

            
            var myStats = System.getSystemStats();
            System.println("Memory3: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            myStats = null;
            
            

            //deBug("pp", $.pp);
            //deBug("cc", $.cc);
            const_proc++;
    }

    
    
    if (const_proc >= pprez.size()) { const_finished = true;}
    if (hipp_finished && const_finished) {
        //deBug("hippconst_finished", const_finished);
        temp_PPIndex = [{},{},{},{},{},{},{},{},{},{},{},{},{},];
        $.hippconst_finished = true;
        $.started = true;
    }
}

function ppHasKey(key) {
    return pp_hipp.indexOf(key)>0;
    /* for (var i = 0; i<pp.size();i++) {
        if (pp[i].hasKey(key)){ return true;}
    }
    return false;
    */
}

//null if it doesn't exist
function ppReturnKey(key) {
    //var ret = pp_hipp.indexOf(key);
    //if (ret == -1) { ret = null;}
    
    var ret2 = null;
    
    for (var i = 0; i<temp_PPIndex.size();i++) {
        if (temp_PPIndex[i].hasKey(key)){ 
            ret2 = temp_PPIndex[i][key];
            break;
        }
    }
    //return null;
    //deBug("ppretkey", [ret, ret2]);

    return ret2;
}

/*
function ppKeys(){
    var ret = [];
    for (var i=0;i<pp.size();i++) {

    var keys = pp[i].keys();
        for (var j=0;j<keys.size();j++) {
            //var myStats = System.getSystemStats();
            //System.println("Memory3: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            //deBug("ppikeys", [i,j]);
            //myStats = null;

            ret.add([i.toNumber(),keys[j].toNumber()]);
            //ret.add(keys[j]);
        }
    }
    return ret;
}
*/

/*
var currPPKeys = [];
var currDict = 0;
var currItem = 0;

function ppNextStar(restart) {
    if (currDict >= pp.size() || restart) {
        currPPKeys = [];
        currDict = 0;
        currItem = 0;
        //deBug("PPNS RET", [currDict,currItem]);
        return null;

    }
    if (currItem == 0 || currPPKeys == null) {
        currPPKeys = pp[currDict].keys();
    }
    var ret = ([pp[currDict][currPPKeys[currItem]], currDict,currPPKeys[currItem]]);
    //deBug("ppns", [currDict,currItem, currPPKeys[currItem], pp[currDict].size(), ret]);
    currItem++;
    if (currItem >= pp[currDict].size()) {
        currDict++;
        currItem = 0;
        currPPKeys = [];
    }
    
    return ret;

}
*/

/*
function removeStar (star) {
    pp_az[star] = null;

}
*/

////////////////////////////////////////////////////////
/* RETURNS NEXT STAR IN QUEUE
/* SKIPPING THOSE THAT ARE IN A CONSTELLATION (WHICH
/* ARE PLOTTED SEPARATELY
*******************************************************/
var currItem = 0;

function ppNextStar(restart, skipConst) {

        if (currItem >= pp_hipp.size() || restart) {    
            
            currItem = 0;
        //deBug("PPNS RET", [currDict,currItem]);
            return null;
        }

        while (skipConst != null && skipConst && currItem < pp_hipp.size() && pp_inConst[currItem]!= null && pp_inConst[currItem]) {
        //var i = pp_hipp[currItem];
            currItem++;
        }
        if (currItem >= pp_hipp.size()) {
            return null;
        } 
        var ret =[pp_az[currItem], pp_alt[currItem], pp_mag[currItem]];
        //deBug("ppnextstar", ret);
        currItem++;
        return ret;

}
    


