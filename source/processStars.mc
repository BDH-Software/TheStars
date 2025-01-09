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
(:hasByteArray)
var pp_ra as Lang.ByteArray = []b;
(:hasByteArray)
var pp_dec as Lang.ByteArray = []b;
(:hasByteArray)
var pp_mag as Lang.ByteArray = []b;

//(:noByteArray)
//var ret as Lang.ByteArray = [];
(:noByteArray)
var pp_ra as Lang.ByteArray = [];
(:noByteArray)
var pp_dec as Lang.ByteArray = [];
(:noByteArray)
var pp_mag as Lang.ByteArray = [];


typedef pp_hipp as Array<Number>;
typedef cc_name as Array<String>;
typedef cc_stars as Array<Array<String>>;

var pp_hipp = [];
var cc_name = [];
var cc_stars = [];

var hippconst_finished = false;
var hipp_proc = 0;
var const_proc = 0;
var hipp_finished = false;
var const_finished = false;

function processStars_init(){
    //pp = [{},{},{},{},{}];
    cc = {};
    //ret = [3]b;
    hippconst_finished = false;
    hipp_proc = 0;
    const_proc = 0;
    hipp_finished = false;
    const_finished = false;
    started = false;

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
            var ppsz = sz/5 + 1;
            for (var i =0; i<sz; i++) {
                var star = pp_orig[kys[i]];
                if (normalize180(lastLoc[0] - star[2]).abs()>95) {
                    //pp_orig.remove(kys[i]);
                    //deBug("omit", [kys[i], star]);
                } else {
                    //var ret as Lang.ByteArray = [];
                    //deBug("256b",[star[1]*256/360, (star[1]*256/360).toChar(), (star[1]*256/360 ) & 256]);
                    pp_hipp.add(kys[i].toNumber());
                    pp_ra.add(star[1]*256/360); //remember they are listed in order MAG, RA, DECL
                    pp_dec.add(star[2]);
                    pp_mag.add(star[0]);

                    deBug("PP_", [star,kys[i].toNumber(),star[1]*256/360, star[2], star[0] ] );
                    /*
                    ret = []b;
                    ret.add(star[0]) as Lang.ByteArray;
                    ret.add((star[1]*256/360)) as Lang.ByteArray;
                    ret.add(star[2]) as Lang.ByteArray;
                    //pp.put((kys[i]).toNumber(), ret);
                    //deBug("PPPPQ0",[kys[i].toNumber(), ret, star, $.pp.size()]);
                    var dict = i/ppsz;
                    $.pp[dict].put((kys[i].toNumber()), ret);                    
                    //deBug("PPPPQ1",[kys[i].toNumber(), ret, star]);
                    */
                }   
            }
            kys = null;
            pp_orig = null;
            hipp_proc++;
    }

        
    if (hipp_proc >= pprez.size()) { 
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
                    var tal = 0;
                    var himag = 10000000;
                    for (var k = 0; k<cnst.size();k++) {
                        var star = cnst[k].toNumber();
                        //if ($.pp.hasKey(star)) {
                        var starK = ppReturnKey(star);
                        if (starK != -1) {
                            tal++;
                            //var mag = pp[starK[0]][starK[1]][0];
                            var mag = pp_mag[starK];
                            if (mag < himag) { himag = mag;}
                            
                        }                        
                    }
                    //if (tal*100/cnst.size()>50 && himag < 45) {
                    if (tal*100/cnst.size()>5) {
                        //deBug("adding", [key, tal, himag, cnst.size()]);
                        //$.cc.put(key,cnst);
                        cc_name.add(key);
                        cc_stars.add(cnst);
                        //deBug("adding", [key, tal, himag, cnst.size()]);
                    } else {
                        //deBug("omitting", [key, tal, himag, cnst.size()]);
                    }
                }
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
        deBug("hippconst_finished", const_finished);
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
    return pp_hipp.indexOf(key);
    
    /*for (var i = 0; i<pp.size();i++) {
        if (pp[i].hasKey(key)){ return [i,key];}
    }
    return null; */
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

var currItem = 0;

function ppNextStar(restart) {
        if (currItem >= pp_hipp.size() || restart) {
        
            
            currItem = 0;
        //deBug("PPNS RET", [currDict,currItem]);
            return null;
        }
        //var i = pp_hipp[currItem];
        var ret = [pp_ra[currItem], pp_dec[currItem], pp_mag[currItem]];
        currItem++;
        return ret;

}
    


