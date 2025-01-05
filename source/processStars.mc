import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.System;
import Toybox.Math;



var pp = {};
var cc = {};
var ret as Lang.ByteArray = [3]b;
var hipp_proc = 0;
var const_proc = 0;
var hipp_finished = false;
var const_finished = false;
var hippconst_finished = false;

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
    
    ];


    //for (var j = 0; j < pprez.size(); j++) {
    var j = hipp_proc;
    if (j < pprez.size()) {

            pp_orig= WatchUi.loadResource( pprez[j]) as Dictionary;

            //get rid of any stars that cannot be seen from this latitude (sloppy filter >85 instead aof >90 to reduce size a bit more)
            var kys = pp_orig.keys();
            //deBug("pppor",[pp_orig,kys]);
            for (var i =0; i<kys.size(); i++) {
                var star = pp_orig[kys[i]];
                if (normalize180(lastLoc[0] - star[2])>85) {
                    //pp_orig.remove(kys[i]);
                    //deBug("omit", [kys[i], star]);
                } else {
                    //var ret as Lang.ByteArray = [];
                    //deBug("256b",[star[1]*256/360, (star[1]*256/360).toChar(), (star[1]*256/360 ) & 256]);
                    ret = []b;
                    ret.add(star[0]) as Lang.ByteArray;
                    ret.add((star[1]*256/360)) as Lang.ByteArray;
                    ret.add(star[2]) as Lang.ByteArray;
                    //pp.put((kys[i]).toNumber(), ret);
                    $.pp.put((kys[i].toNumber()), ret);
                    deBug("PPPPQ1",[kys[i].toNumber(), ret, star]);
                }   
            }
            kys = null;
            pp_orig = null;
            hipp_proc++;
    }

    
    
    if (hipp_proc >= pprez.size()) { hipp_finished = true;}
    
    pprez = [$.Rez.JsonData.constellations_stellarium_1,
    $.Rez.JsonData.constellations_stellarium_2,
    $.Rez.JsonData.constellations_stellarium_3,
    $.Rez.JsonData.constellations_stellarium_4,
    $.Rez.JsonData.constellations_stellarium_5,
    $.Rez.JsonData.constellations_stellarium_6,
    $.Rez.JsonData.constellations_stellarium_7,
    
    
    ];


            var myStats = System.getSystemStats();
            System.println("Memory2: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            myStats = null;

    j = const_proc;
    if (hipp_finished && j < pprez.size()) {
            //for (var j = 0; j < pprez.size(); j++) { 
                pp_orig = WatchUi.loadResource( pprez[j]) as Dictionary;
                var kys = pp_orig.keys();
                for (var i = 0; i<kys.size(); i++) {
                    var key = kys[i];
                    var cnst = pp_orig[key];
                    var tal = 0;
                    var himag = 10000000;
                    for (var k = 0; k<cnst.size();k++) {
                        var star = cnst[k].toNumber();
                        if ($.pp.hasKey(star)) {
                            tal++;
                            var mag = pp[star][0];
                            if (mag < himag) { himag = mag;}
                            
                        }                        
                    }
                    //if (tal*100/cnst.size()>50 && himag < 45) {
                    if (tal*100/cnst.size()>5) {
                        //deBug("adding", [key, tal, himag, cnst.size()]);
                        $.cc.put(key,cnst);
                        deBug("adding", [key, tal, himag, cnst.size()]);
                    } else {
                        deBug("omitting", [key, tal, himag, cnst.size()]);
                    }
                }
            //}

            myStats = System.getSystemStats();
            System.println("Memory3: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            myStats = null;
            

            //deBug("pp", $.pp);
            //deBug("cc", $.cc);
            const_proc++;
    }

    
    
    if (const_proc >= pprez.size()) { const_finished = true;}
    if (hipp_finished && const_finished) {hippconst_finished = true;}
}

function starsTimer() {

} 

