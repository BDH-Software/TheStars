//Copyright Brent Hugh
//License available at project GitHub page:
//https://github.com/bhugh/ThePlanets

//Garmin App UUID for current version in IQ Store: 153a34d3-72a7-4453-a803-ed94083e4180

import Toybox.Application;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.System;
import Toybox.Math;
import Toybox.Application.Storage;
import Toybox.Activity;

var view_mode;
var lastLoc;
var hz = 10f;


//var page = 0;
//var pages_total = 25;
//var geo_cache;
//var sunrise_cache;
//var moon;

//var vspo87a;
//var vsop_cache;
//var allOrbitParms = null;
    //var view_mode = [0, 1,2,3,4,5]; //manual move ecl, minuts ecl, day ecl, inner orr, mid orr, full orr
    //var view_mode = 1;
    //var num_view_modes = 9;

    //unit is HOUR
    //all are chosen to be WHOLE DAYS however, to make the sun stand still when moving forward on the eliptical screens
    //But also closest unit to WHOLE YEARS (ie 183 instead of 180 or 182.621187, 61 instead of 60 or 60.873729)
    //Adde synodic month & solar yr as exact time options
    /*var speeds = [-24*365*10, -24*365*7, -24*365*4, -24*365*2,-24*365.2422, -24*365, //0; year multiples (added 0)
                -24*183, -24*122, -24*91, -24*61, -24*31, -29.53059*24, -24*15, //6; 1/2, 1/4, 1/12, 1/24 of a year (added 1)
                -24*7,-24*5, -24*3, -24*2-15/60.0, -24*2, -24*2+15/60.0, -24-15/60.0, -24, -24+15/60.0, //11; Days up to a week, with 1&2 days +1/-1 hrsso you can adjust them easily
                -12,-6,-4,-2, -1, //22;Hours (added 1)
                -30/60.0,-15/60.0,-10/60.0, -5/60.0, -3/60.0, -2/60.0, -1/60.0,  //27; minutes (added 0)
                1/600000.0,  //34; Zero ( but still has very slight movement, also avoids /0 just in case)
                1/60.0, 2/60.0, 3/60.0, 5/60.0, 10/60.0, 15/60.0, 30/60.0,  //35; minutes (added 0)
                1,2,4,6,12,  //42; Hours (added 1)
                24-15/60.0, 24,24+15/60.0, 24*2-15/60.0, 24*2,24*2+15/60.0, 24*3,24*5, 24*7, //47; Days up to a week (added 0)
                24*15,29.53059*24, 24*31, 24*61, 24*91, 24*122, 24*183, 24*300, //56;300 days 1/2, 1/4, 1/12, 1/24 of a year (added 1)
                24*365,24*365.2422, 24 * 400, 24 * 500, 24*365*2, 24*365*4, 24*365 * 7, 24*365 * 10]; //64; year multiples (added 0)*/
var speeds;
var speeds_index; //the currently used speed that will be added to TIME @ each update of screen  //
//var screen0Move_index = 33;

var started = false; //whether to move forward on an update, ie STOPPED or STARTED moving
var start_time_sec = 0;
var last_button_time_sec = 0;
var save_started = null;
var reset_date_stop = false; //set TRUE when reset date is called, which STOPS time.
//var hz = 5.0; //updates per second (Requested from OS)
var run_oneTime = true; //set to TRUE by anything that once the screeupdate to run ONCE when it is stopped

var message = [];
var message_until = 0;
var animation_count = 0;
var buttonPresses = 0;
var orreryDraws = 0;

var time_add_hrs = 0.0; //cumulation of all time to be added to time.NOW when a screen is displayed

var show_intvl = 0; //whether or not to show current SPEED on display
var animSinceModeChange = 0; //used to tell when to blank screen etc.
var solarSystemView_class as SolarSystemBaseView?; //saved instance of main class 

//enum {exitApp, resetDate, orrZoomOption, thetaOption, labelDisplayOption, refreshOption, screen0MoveOption, planetSizeOption, planetsOption, helpOption, helpBanners}

//enum {EXIT_APP, RESET_DATE, ORR_ZOOM, THETA, LABEL_DISPLAY, REFRESH, PLANET_SIZE, PLANETS, HELP, HELP_BANNERS}

//By specifying values here, they will not change so ie the program STORAGE will not get messed up
//if we add a new enum.  Never change the VALUE of an enum once established.  YOu
//can just remove it or add another interspersed, but give the new one a new unique VALUE.
enum {changeMode_enum= 0,
        resetDate_enum= 1,
        orrZoomOption_enum= 2,
        thetaOption_enum= 3,
        labelDisplayOption_enum= 4,
        refreshOption_enum= 5,
        gpsOption_enum= 15, //giving these new numbers so they won't read anything old in the storage
        latOption_enum= 16, // "
        lonOption_enum= 17, // "
        planetSizeOption_enum= 6,
        planetsOption_enum= 7,
        helpOption_enum= 8,
        helpBanners_enum= 9,
        lastLoc_enum = 10,
        } //screen0MoveOption_enum, 


class SolarSystemBaseApp extends Application.AppBase {

    //enum {ECLIPTIC_STATIC, ECLIPTIC_MOVE, SMALL_ORRERY, MED_ORRERY, LARGE_ORRERY}
    //var view_mode = [ECLIPTIC_STATIC, ECLIPTIC_MOVE, SMALL_ORRERY, MED_ORRERY, LARGE_ORRERY];


    private var _solarSystemView as SolarSystemBaseView?;
    private var _solarSystemDelegate as SolarSystemBaseDelegate?;

    //! Constructor
    public function initialize() {
        AppBase.initialize();
        System.println("init starting...");
        
        //geo_cache = new Geocentric_cache();
        
        $.now = System.getClockTime();
        $.time_now = Time.now();
        $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);
        $.start_time_sec = $.time_now.value(); //start time of app in unix seconds

        //do this AFTER getting time & reading init storage values
        //_solarSystemView = new $.SolarSystemBaseView();
        //solarSystemView_class = _solarSystemView;
        //_solarSystemDelegate = new $.SolarSystemBaseDelegate(_solarSystemView);
        

        //These  2 must be done AFTER View class is inited
        //readStorageValues();
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
        setInitPosition();

        //sunrise_cache = new sunRiseSet_cache2();        //works fine but not using it now..
        //System.println("inited...");
        view_mode=1;
        //$.changeModes(null); //inits speeds_index properly        


        //System.println("ARR" + toArray("HI|THERE FRED|M<SYUEIJFJ |FIEJKDF:LKJF|SKDJFF|SDLKJSDFLKJ|THIESNEK|FJIEKJF","|",0));

        
        
        

    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {  
        //System.println("onStart...");
        $.started = false;
        //$.run_oneTime = true;
        //$.timeWasAdded = true;
        $.buttonPresses = 0;
        $.animation_count = 0;
        //$.countWhenMode0Started = 0;
        $.now = System.getClockTime(); //before ANY routines or functions run, so all can have access if necessary        
        $.time_now = Time.now();
        $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);
        System.println ("onStart at " 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d") + " " + now_info.year + "-" + now_info.month + "-" + now_info.day);

        if (_solarSystemView != null) {
            _solarSystemView.startAnimationTimer($.hz);
        }
        
        
        //readStorageValues();
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
        System.println ("onStop at " 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d"));
        _solarSystemView.stopAnimationTimer();
        started = false;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        _solarSystemView = null;
        _solarSystemDelegate = null;
        //settings_view = null;
        //settings_delegate = null;

    }

    //! Update the current position
    //! @param info Position information
    public function onPosition(info as Position.Info) as Void {
        //System.println("onPosition... count: " + $.count);
        setPosition(info);

    }

    //! Return the initial view for the app
    //! @return Array [View]
    public function getInitialView() as [Views] or [Views, InputDelegates] {
        /*System.println ("getInitialView at " 
            +  now.hour.format("%02d") + ":" +
            now.min.format("%02d") + ":" +
            now.sec.format("%02d"));*/

        processStars();

        _solarSystemView = new $.SolarSystemBaseView();
        //solarSystemView_class = _solarSystemView;
        _solarSystemDelegate = new $.SolarSystemBaseDelegate(_solarSystemView);
        return [_solarSystemView, _solarSystemDelegate];
        _solarSystemDelegate = null;
        _solarSystemView = null;

    }
    /*
    // settingsview works only for watch faces & data fields (?)
    public function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        System.println("6A");
        return [new $.SolarSystemSettingsMenu(), new $.SolarSystemInputDelegate()];
    }
    */

    /*

    public function readAStorageValue(name, defoolt, size  ) {
        if (!(Application has :Storage)) {
            $.Options_Dict[name] = defoolt;
            return;
        }
        var temp = Storage.getValue(name);  
        //System.println((32.0).toNumber() + " " + temp);  
        if (!(temp instanceof Number)) {$.Options_Dict[name] = defoolt;}
        else { $.Options_Dict[name] = temp  != null ? temp : defoolt; }
        if ($.Options_Dict[name]>size-1) {$.Options_Dict[name] = defoolt;}
        if ($.Options_Dict[name]<0) {$.Options_Dict[name] = defoolt;}
        Storage.setValue(name,$.Options_Dict[name]);
    }

    //read stored settings & set default values if nothing stored
    public function readStorageValues() as Void {

        //System.println("STORAGE VALUES ARE READ - PROGRAM INIT!!!!");

        loadPlanetsOpt();
      
        readAStorageValue("orrZoomOption", orrZoomOption_default, orrZoomOption_size );

        //readAStorageValue(orrZoomOption, thetaOption_default, thetaOption_size );

        $.Options_Dict[thetaOption_enum] = 0; //just always default to TIME INTERVAL here.

        readAStorageValue(labelDisplayOption_enum,labelDisplayOption_default, labelDisplayOption_size );

        readAStorageValue(refreshOption_enum,refreshOption_default, refreshOption_size );
        readAStorageValue(latOption_enum,latOption_default, latOption_size );

        readAStorageValue(refreshOption_enum,refreshOption_default, refreshOption_size );
        readAStorageValue(lonOption_enum,lonOption_default, lonOption_size );

        //readAStorageValue("Screen0 Move Option",screen0MoveOption_default, screen0MoveOption_size );

        readAStorageValue(planetSizeOption_enum, planetSizeOption_default, planetSizeOption_size );

        //readAStorageValue("Ecliptic Size Option", eclipticSizeOption_default, eclipticSizeOption_size );
/*
        readAStorageValue("Orbit Circles Option", orbitCirclesOption_default, orbitCirclesOption_size );

        readAStorageValue("resetDots", resetDots_default, resetDots_size );
        */
        /*

        readAStorageValue(planetsOption_enum, planetsOption_default, planetsOption_size );        

        //if you scramble up the order of the enums it will change which enum gets which value
        //so, best not to change the order, or come up with some scheme to check it or whatever
        var temp = Storage.getValue(helpBanners_enum);
        $.Options_Dict[helpBanners_enum] = temp != null ? (temp == true) : true;
        Storage.setValue(helpBanners_enum,$.Options_Dict[helpBanners_enum]); 

        temp = Storage.getValue(gpsOption_enum);
        $.Options_Dict[gpsOption_enum] = temp != null ? (temp == true) : true;
        Storage.setValue(gpsOption_enum,$.Options_Dict[gpsOption_enum]); 

       



        //Now IMPLEMENT the above values

        
        /*
        //#####SCREEN0 MOVE
        $.screen0Move_index = screen0MoveOption_values[$.Options_Dict["Screen0 Move Option"]];
        */
        /*

        //###### REFRESH RATE
        $.hz = refreshOption_values[$.Options_Dict[refreshOption_enum]];                
        _solarSystemView.startAnimationTimer($.hz);           


        
        //###### MANUAL LATITUDE    
        //lat ranges 0 - 181 and lat is either val-90 or if ==181,  auto
        //lon ranges 0 - 361 and lon is either val-180 or if ==361,  auto
        //$.latlonOption_value=[];
        $.latlonOption_value= [$.Options_Dict[latOption_enum], $.Options_Dict[lonOption_enum]];                
            
        //$.hz = lonOption_values[$.Options_Dict[lonOption_enum]];                    
        

        //##### PLANET SIZE
        planetSizeFactor = planetSizeOption_values[$.Options_Dict[planetSizeOption_enum]];

        /*
        //##### ECLIPTIC SIZE
        eclipticSizeFactor = eclipticSizeOption_values[$.Options_Dict["Ecliptic Size Option"]];
        */

        /*

        //##### Display all or only planets
        planetsOption_value = $.Options_Dict[planetsOption_enum]; //the number not the array (unusual) 

        /* //Sample binary option
        temp = Storage.getValue("Show Battery");
        $.Options_Dict["Show Battery"] = temp  != null ? temp : true;
        Storage.setValue("Show Battery",$.Options_Dict["Show Battery"]);        
        */

     
        /*
    }
*/

}

/*  SAMPLEs..
class SolarSystemInputDelegate extends WatchUi.InputDelegate {
    function onKey(keyEvent) {
        System.println("GOT KEEY!!!!!!!!!: " + keyEvent.getKey());         // e.g. KEY_MENU = 7
        return true;
    }

    function onTap(clickEvent) {
        System.println(clickEvent.getType());      // e.g. CLICK_TYPE_TAP = 0
        return true;
    }

    function onSwipe(swipeEvent) {
        System.println(swipeEvent.getDirection()); // e.g. SWIPE_DOWN = 2
        return true;
    }
}

*/
/*
  function setPositionFromManual() as Boolean {
        //deBug("SIP 2", null);
        if ($.Options_Dict[gpsOption_enum]) { return false;}
        if ($.latlonOption_value[0] < 0) {$.latlonOption_value[0] = 0;}
        if ($.latlonOption_value[0] > 180) {$.latlonOption_value[0] = 180;}
        if ($.latlonOption_value[1] < 0) {$.latlonOption_value[1] = 0;}
        if ($.latlonOption_value[1] > 360) {$.latlonOption_value[1] = 360;}
        //deBug("SIP 3", null);
        lastLoc= [$.latlonOption_value[0]-90, $.latlonOption_value[1]-180];
        //deBug("SIP 4", lastLoc);
        return true;       
    }
    */

    //Until setPosition gets a callback we will use SOME value for lastLoc
    //We call setInitPosition immeidately upon startup & then setPosition will fill in
    //later as correct data is available.
    function setInitPosition () {        
        //lastLoc = [-70.00894, -179.44008]; //for testing
        //lastLoc = [-60.00894, 179.44008]; //for testing
        //lastLoc = [39.00894, -94.44008]; //for testing
        //lastLoc = [59.00894, -94.44008]; //for testing
        //lastLoc = [0,0]; //for testing
        //lastLoc = [51.5, 0]; //for testing - Greenwich
        //deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TESTINGTESTINGTESTING LAT/LONG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", lastLoc);
        //return;

        //in case MANUAL POSITION set in settings
        //deBug("SIP 1", null);
        
        setPosition(null);

        /*

        //this is pretty much redundant with setPosition now, could be removed??
        if (lastLoc == null ) {
            if (lastLoc == null) {self.lastLoc = new Position.Location(            
                        { :latitude => 39.833333, :longitude => -94.583333, :format => :degrees }
                        ).toDegrees(); }
            if ($.Options_Dict.hasKey(lastLoc_enum)) {lastLoc = $.Options_Dict[lastLoc_enum];}
            
            var temp = Storage.getValue(lastLoc_enum);
            if (temp!=null) {lastLoc = temp;}
            Storage.setValue(lastLoc_enum, lastLoc);
            $.Options_Dict.put(lastLoc_enum, lastLoc);
        }
        //System.println("setINITPosition at " + animation_count + " to: "  + lastLoc);
        */
    //}

    }

    //fills in the variable lastLoc with current location and/or
    //several fallbacks
    function setPosition (pinfo as Position.Info) {
        System.println ("setPosition");

        //We only need this ONCE, not continuously, so . . . 
        //Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:setPosition));

        //lastLoc = [0,0]; //for testing
        //lastLoc = [51.5, 0]; //for testing - Greenwich
        //lastLoc = [39.00894, -94.44008]; //for testing
        //lastLoc = [-60.00894, 179.44008]; //for testing
        //lastLoc = [-70.00894, -179.44008]; //for testing
        //deBug("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!TESTINGTESTINGTESTING LAT/LONG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!", lastLoc);        
        //return;

        //in case MANUAL POSITION set in settings
        //var man_set = setPositionFromManual(); //will be TRUE if the position is set manually
        //We still go ahead & try to determine the actual GPS position & save it in options_dict & storage
        //for future use

        //if (info == null || info.position == null) { pinfo = Position.getInfo(); }
        //System.println ("sc1: Null? " + (pinfo==null));
        //if (pinfo != null ) {deBug ("setPosition getting position from OS:",  pinfo.position.toDegrees());}

        var curr_pos = null;
        if (pinfo!= null && pinfo.position != null) { curr_pos = pinfo.position; }
        else { //if there is nothing in the pinfo passed to us we just try to grab it now (ie, at init)
            pinfo = Position.getInfo(); 
            if (pinfo!= null && pinfo.position != null) { curr_pos = pinfo.position; }
        }
        
        var temp = curr_pos.toDegrees()[0];
        if ( (temp - 180).abs() < 0.1 || temp.abs() < 0.1 ) {curr_pos = null;} //bad data
        

        /*
        //this is giving errors, IQ! screen on wathc???///???!!!!
        //so just removing for now  2024/12/11
        try {
            if (curr_pos == null && Toybox has :Weather) {

                if (Toybox has :Weather) {
            		var currentConditions = Weather.getCurrentConditions();
                    if (currentConditions != null && currentConditions.observationLocationPosition != null) {
                    curr_pos = currentConditions.observationLocationPosition;
                    }
	            }
                if (curr_pos != null && curr_pos has :toDegrees) {
                    temp = curr_pos.toDegrees()[0];
                    if ( temp == null || temp == 180 || temp == 0 ) {curr_pos = null;} //bad data
                }
            }
        } catch (e instanceof Lang.Exception) {
            System.println("This device does not have Toybox.Weather - skipping this method of obtaining position information. Error: " + e);
        }

        */

        if (curr_pos == null) {
            var a_info = Activity.getActivityInfo();
            var a_pos = null;
            //System.println ("sc1.2:Activity a_pos==Null3? " + (a_pos==null));
            
            if (a_info!=null && a_info has :position && a_info.position != null)
            { a_pos = a_info.position;}
            if (a_pos != null ) {
                //System.println ("sc1.2: a_pos " + a_pos.toDegrees());
                curr_pos = a_pos; 
            }
        }
        

        //System.println ("sc1a:");
        //In case position info not available, we'll use either the previously obtained value OR the geog center of 48 US states as default.
        //|| info.accuracy == Pos.QUALITY_NOT_AVAILABLE 

        var new_lastLoc = null;
        //if ($.Options_Dict.hasKey(lastLoc_enum)) {new_lastLoc = $.Options_Dict[lastLoc_enum];}

        var rt = Storage.getValue(lastLoc_enum);
        if (rt != null) {new_lastLoc = rt;}


        if (curr_pos == null ){
           if (new_lastLoc == null) { 
                var long = -98.583333; 

                //approximate longitude from time zone offset if no other option
                $.now = System.getClockTime();
                if ($.now != null && $.now.timeZoneOffset != null) { long = $.now.timeZoneOffset/3600*15;}

                new_lastLoc = new Position.Location(            
                    { :latitude => 39.833333, :longitude => long, :format => :degrees }
                    ).toDegrees();
                    //System.println ("sc1b: " + self.lastLoc);
           }
        } else {

            var loc = curr_pos.toDegrees();
            new_lastLoc = loc;
            //System.println ("sc1c:"+ curr_pos.toDegrees());
            //System.println ("sc1c");
        }        


        //System.println ("sc2");
        
        //$.Options_Dict["Location"] = [self.lastLoc, $.now.value()];
        //Storage.setValue("Location",$.Options_Dict["Location"]);
        //System.println ("sc3");
        /* For testing
           now = new Time.Moment(1483225200);
           self.lastLoc = new Pos.Location(
            { :latitude => 70.6632359, :longitude => 23.681726, :format => :degrees }
            ).toRadians();
        */
        //System.println ("lastLoc: " + lastLoc );

        if (new_lastLoc != null) {
            //$.Options_Dict.put(lastLoc_enum, new_lastLoc);
            Storage.setValue(lastLoc_enum, new_lastLoc);
        }
        
        self.lastLoc = new_lastLoc; //if man_set is true, then we don't want to update self.lastLoc with the new value, we want to keep the value that was set by the user.

        //System.println("setPosition (from GPS, final) at " + animation_count + " to: "  + new_lastLoc + " manual GPS mode?" + man_set + " final SET pos: " + self.lastLoc);
        //return man_set;
        return;
    }