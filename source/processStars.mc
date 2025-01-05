import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.System;
import Toybox.Math;


var pp_orig = {};
var pp = {};
var cc = {};
var ret as Lang.ByteArray = [3]b;

function processStars(){


    pp_orig= WatchUi.loadResource( $.Rez.JsonData.hipparcos4) as Dictionary;

            //get rid of any stars that cannot be seen from this latitude (sloppy filter >85 instead aof >90 to reduce size a bit more)
            var kys = pp_orig.keys();
            deBug("pppor",[pp_orig,kys]);
            for (var i =0; i<kys.size(); i++) {
                var star = pp_orig[kys[i]];
                if (normalize(lastLoc[0] - star[2])>85) {
                    pp_orig.remove(kys[i]);
                    deBug("remove", [kys[i], star]);
                } else {
                    //var ret as Lang.ByteArray = [];
                    deBug("256",[star[1]*256/360, (star[1]*256/360).toChar(), (star[1]*256/360 ) & 256]);
                    ret = [3]b;
                    ret.add(star[0]) as Lang.ByteArray;
                    ret.add((star[1]*256/360)) as Lang.ByteArray;
                    ret.add(star[2]) as Lang.ByteArray;
                    //pp.put((kys[i]).toNumber(), ret);
                    pp.put((kys[i].toNumber()), ret);
                    deBug("PPPP",[kys[i].toNumber(), ret]);
                }   
            }
            kys = null;
            pp_orig = null;

            var myStats = System.getSystemStats();
            System.println("Memory2: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            myStats = null;


            cc = WatchUi.loadResource( $.Rez.JsonData.constellations_stellarium) as Dictionary;

            myStats = System.getSystemStats();
            System.println("Memory3: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
            myStats = null;

            deBug("pp", pp);
            deBug("cc", cc);
}