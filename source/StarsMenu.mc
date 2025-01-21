
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;
import Toybox.Position;

//var sssMenu_class; //to save the SolarSystemSettingsMenu class for access

enum {
    CONSTLINES,
    CONSTNAMES,
    ALLBOLDER,
    REVERSECOLORS,
    TIMEDIRECTION,
    ADDHOURS,  
    ADDDAYS,
    ADDMONTHS,
    ADDYEARS,
    ADDDECADES,
    ADDCENTURIES,
    CONSTNAMEHELP0,
    CONSTNAMEHELP1,
    LONGNAMES,
    COMPASSMOVE,
    COMPASSPOINT,
    GPSOPTION= 115, //giving these new numbers so they won't read anything old in the storage
    LATOPTION= 116, // "
    LONOPTION= 117, // "
    lastLoc_enum =10,
}

/*
function cleanUpSettingsOpt(){
    //changeModeOption = null;
    orrZoomOption = null;
    labelDisplayOption = null;
    planetsOption = null;
    planetSizeOption = null;
    thetaOption = null;
    refreshOption = null;
    allPlanets = null;

}
*/

var Options_Dict = {};
//var _updatePositionNeeded = false;
//var _rereadGPSNeeded = false;

var latOption_size = 181;  //ranges 0 to 180; lat is value-90
var latOption_default = 90;

var lonOption_size = 362;  //ranges 0 to 360; lat is value-180
var lonOption_default = 180;

var latlonOption_value= [90,180];    

//! The app settings menu
class StarsMenu extends WatchUi.Menu2 {

    
    
    

    


    //! Constructor
    public function initialize() {
        //sssMenu_class = self;    

        
        //loadSettingsOpt();
        _updatePositionNeeded = false;



       deBug("menu3", null);


        Menu2.initialize({:title=>WatchUi.loadResource($.Rez.Strings.settingsTitle) as String});
        
        
        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.compassMove) as String, null, COMPASSMOVE, $.Options_Dict[COMPASSMOVE], null));

        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.compassPoint) as String,(WatchUi.loadResource($.Rez.JsonData.compassPoint_options) as Array)[ $.Options_Dict[COMPASSPOINT]], COMPASSPOINT, {}));   
        

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.constLines) as String, null, CONSTLINES, $.Options_Dict[CONSTLINES], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.constNames) as String, null, CONSTNAMES, $.Options_Dict[CONSTNAMES], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.longNames) as String, null, LONGNAMES, $.Options_Dict[LONGNAMES], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.allBolder) as String, null, ALLBOLDER, $.Options_Dict[ALLBOLDER], null));  

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.reverseColors) as String, null, REVERSECOLORS, $.Options_Dict[REVERSECOLORS], null));         

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.uagp) as String, null, GPSOPTION, $.Options_Dict[GPSOPTION], null));       
                
        if ($.Options_Dict[LATOPTION] == null) { $.Options_Dict[LATOPTION] = $.latOption_default; }
        var val = ($.Options_Dict[LATOPTION] - 90);        
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.mlat) as String, val.toString(),LATOPTION,{})); 
            
        if ($.Options_Dict[LONOPTION] == null) { $.Options_Dict[LONOPTION] = $.lonOption_default; }
        val = $.Options_Dict[LONOPTION] - 180;            
        Menu2.addItem(new WatchUi.MenuItem(WatchUi.loadResource($.Rez.Strings.mlon) as String,val.toString(),LONOPTION,{}));

deBug("menu4", null);
           

        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_hrs.toString() + " hours", ADDHOURS, null));   
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_days.toString() + " days", ADDDAYS, null));   
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_months.toString() + " months", ADDMONTHS, null));   
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_years.toString() + " years", ADDYEARS, null));  
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_decades.toString() + " decades", ADDDECADES, null));
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_centuries.toString() + " centuries", ADDCENTURIES, null)); 
        var dir = $.time_add_direction == 1 ? "Forward" : "Backward";
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeDirection) as String), dir, TIMEDIRECTION, null)); 

        var cA = getConstellationAbbreviation(0);
        //constellationAbbreviation_index = pA[1];
        //deBug("menu2", [cA, cA[0], cA[1], CONSTNAMEHELP]);
        Menu2.addItem(new WatchUi.MenuItem(cA[0], cA[1], CONSTNAMEHELP0, null));

        cA = getConstellationAbbreviation(1);
        //constellationAbbreviation_index = pA[1];
        
        Menu2.addItem(new WatchUi.MenuItem(cA[0], cA[1], CONSTNAMEHELP1, null));
        
        deBug("menu5", null);              

    }
}

//! Input handler for the app settings menu
class StarsMenuDelegate extends WatchUi.Menu2InputDelegate {

    var changeTime = false;
    

    var mainView;
    //! Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
        
    }

        //! Handle a menu item being selected
    //! @param menuItem The menu item selected
    public function onSelect(menuItem as MenuItem) as Void {
        
        

        var ret = menuItem.getId() as String;
        
            
        if (menuItem instanceof ToggleMenuItem) {

                if (ret != null && ret.equals(GPSOPTION)) {
                
                /* 
                $.time_add_hrs = 0;
                $.started=false;
                $.reset_date_stop = true;
                $.run_oneTime = true;
                $.LORR_show_horizon_line = true;
                */
                //NOT going to store this, so that autoGPS is
                //enabled whenever the program starts.  They can
                //manually switch to their set GPS coordinates if they want.
                //Storage.setValue(ret, menuItem.isEnabled());
                $.Options_Dict[ret] = menuItem.isEnabled();
                //$.solarSystemView_class.setInitPosition();
                //$.jumpToGPS = true;                
                //WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                
                //instead of just doing this here, we wait until the MENU
                //has closed, thus saving memory.  Also only read GPS
                //again if really needed.
                //We were having memory faults here when reading GPS with menu open
                //GPS/position is inited in onupdate view, only when these flags are set
                _updatePositionNeeded = true;
                //if (menuItem.isEnabled) {_rereadGPSNeeded = true;}
                

                //var settings_view = new $.SolarSystemSettingsView();
                //var settings_delegate = new $.SolarSystemSettingsDelegate();
        
                //pushView(settings_view, settings_delegate, WatchUi.SLIDE_IMMEDIATE);
                
            } else if (ret != null){
                          
                Storage.setValue(ret, menuItem.isEnabled());
                $.Options_Dict[ret] = menuItem.isEnabled();                        
                
            }            
           
        } else 

        if (menuItem instanceof MenuItem) {    
            if (ret != null && ret.equals(COMPASSPOINT)) {

                $.Options_Dict[COMPASSPOINT] = ($.Options_Dict[COMPASSPOINT]  + 1 ) %3;
                menuItem.setSubLabel((WatchUi.loadResource($.Rez.JsonData.compassPoint_options) as Array)[ $.Options_Dict[COMPASSPOINT]]);           
                
            } else

            if (ret != null && ret.equals(ADDHOURS)) {

                $.time_add_hrs = ($.time_add_hrs + 1)%24;
                changeTime = true;   
                menuItem.setSubLabel(time_add_hrs.toString() + " hours");           
                $.time_changed = true;                  
                
            } else if (ret != null && ret.equals(ADDDAYS)) {

                $.time_add_days = ($.time_add_days + 1)%31;
                changeTime = true;   
                menuItem.setSubLabel( time_add_days.toString() + " days");   
                $.time_changed = true;                       
                
            } else if (ret != null && ret.equals(ADDMONTHS)) {

                $.time_add_months = ($.time_add_months + 1)%12;
                changeTime = true;   
                menuItem.setSubLabel(time_add_months.toString() + " months");       
                $.time_changed = true;                     
                
            
            } else if (ret != null && ret.equals(ADDYEARS)) {

                $.time_add_years = ($.time_add_years + 1)%10;
                changeTime = true;   
                menuItem.setSubLabel(time_add_years.toString() + " years");       
                $.time_changed = true;  

            } else if (ret != null && ret.equals(ADDDECADES)) {

                $.time_add_decades = ($.time_add_decades + 1)%10;
                changeTime = true;   
                menuItem.setSubLabel(time_add_decades.toString() + " decades");       
                $.time_changed = true;                       
                
            } else if (ret != null && ret.equals(ADDCENTURIES)) {

                $.time_add_centuries = ($.time_add_centuries + 1);
                changeTime = true;   
                menuItem.setSubLabel(time_add_centuries.toString() + " centuries");       
                $.time_changed = true;                       
                
            } 
            
            else if (ret != null && ret.equals(TIMEDIRECTION)) {
                $.time_add_direction = - $.time_add_direction;
                var dir = $.time_add_direction == 1 ? "Forward" : "Backward";                
                changeTime = true;   
                menuItem.setSubLabel(dir);       
                $.time_changed = true;                       
                
            }   else if(ret != null && ret.equals(CONSTNAMEHELP0)) {            
                    var cA = getConstellationAbbreviation(0);            
                    menuItem.setLabel(cA[0]);
                    menuItem.setSubLabel(cA[1]);
            } 
              else if(ret != null && ret.equals(CONSTNAMEHELP1)) {            
                    var cA = getConstellationAbbreviation(1);            
                    menuItem.setLabel(cA[0]);
                    menuItem.setSubLabel(cA[1]);
            }
            else if (ret != null && ret.equals(LATOPTION)) 
            {
                $.Options_Dict[ret]=($.Options_Dict[ret]+5)%latOption_size;
                menuItem.setSubLabel(($.Options_Dict[ret]-90).toString());
                //else {menuItem.setSubLabel("GPS");}

                Storage.setValue(ret as String, $.Options_Dict[ret]); 
                
                $.latlonOption_value[0] = $.Options_Dict[ret];     
                //$.solarSystemView_class.setInitPosition();       
                _updatePositionNeeded = true;
            
            } else if(ret != null && ret.equals(LONOPTION))             
            {
                $.Options_Dict[ret]=($.Options_Dict[ret]+10)%lonOption_size;
                menuItem.setSubLabel(($.Options_Dict[ret]-180).toString());
                //else {menuItem.setSubLabel("GPS");}

                Storage.setValue(ret as String, $.Options_Dict[ret]); 
                //[ "5hz", "4hz", "3hz", "2hz", "1hz", "2/3hz", "1/2hz"];
                $.latlonOption_value[1] = $.Options_Dict[ret];  
                //$.solarSystemView_class.setInitPosition();          
                _updatePositionNeeded = true;
            }

        }

    }

   
    function onBack() {
        if (_updatePositionNeeded) {
            $.setPosition(null);
            $.pos_just_changed = true;
        }
        /*
        if (_rereadGPSNeeded ) {
            Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:setPosition));
            $.pos_just_changed
        }
        */
        _updatePositionNeeded = false; 
        _rereadGPSNeeded = false;

        
        //$.cleanUpSettingsOpt();
        if (changeTime) {
            $.time_just_changed = true;

            //var addTime =new Time.Duration($.time_add_direction * ($.time_add_days * 24 * 3600 + $.time_add_months * 30 * 24 * 3600 + $.time_add_hrs * 3600 + $.time_add_years * 365 * 24 * 3600));
            //var t_now = Time.now();

            $.addTime_hrs  =$.time_add_direction * ($.time_add_days * 24 + $.time_add_months * 30 * 24 + $.time_add_hrs + $.time_add_years * 365 * 24 + $.time_add_decades* 10 * 365 * 24+ $.time_add_centuries* 100 * 365 * 24);

            deBug("addTime_hrs", [ $.addTime_hrs, $.addTime_hrs/24.0/365.0]);

            //$.time_now = t_now.add(addTime);

            //deBug("tn", [t_now, $.time_now, t_now instanceof Time.Moment, $.time_now instanceof Time.Moment]);

            //$.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);            

        } 

        $.heading_from_watch = true;
        
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
    

    }

        
}


function readStorageValues(){
    var temp = Storage.getValue(COMPASSMOVE);
    $.Options_Dict[COMPASSMOVE] = temp != null ? (temp == true) : false; //last one is the default
    Storage.setValue(COMPASSMOVE,$.Options_Dict[COMPASSMOVE]); 

    temp = Storage.getValue(COMPASSPOINT);
    $.Options_Dict[COMPASSPOINT] = (temp != null && temp instanceof Number) ? (temp) : 0; //last one is the default
    Storage.setValue(COMPASSPOINT,$.Options_Dict[COMPASSPOINT]); 

    temp = Storage.getValue(CONSTLINES);
    $.Options_Dict[CONSTLINES] = temp != null ? (temp == true) : true; //last one is the default
    Storage.setValue(CONSTLINES,$.Options_Dict[CONSTLINES]);
    
    temp = Storage.getValue(CONSTNAMES);
    $.Options_Dict[CONSTNAMES] = temp != null ? (temp == true) : true; //last one is the default
    Storage.setValue(CONSTNAMES,$.Options_Dict[CONSTNAMES]);

    temp = Storage.getValue(LONGNAMES);
    $.Options_Dict[LONGNAMES] = temp != null ? (temp == true) : true; //last one is the default
    Storage.setValue(LONGNAMES,$.Options_Dict[LONGNAMES]);

    temp = Storage.getValue(ALLBOLDER);
    $.Options_Dict[ALLBOLDER] = temp != null ? (temp == true) : false; //last one is the default
    Storage.setValue(ALLBOLDER,$.Options_Dict[ALLBOLDER]);

    temp = Storage.getValue(REVERSECOLORS);
    $.Options_Dict[REVERSECOLORS] = temp != null ? (temp == true) : false; //last one is the default
    Storage.setValue(REVERSECOLORS,$.Options_Dict[REVERSECOLORS]);

    temp = Storage.getValue(LATOPTION);
    $.Options_Dict[LATOPTION] = (temp != null && temp instanceof Number) ? (temp) : 90; //last one is the default
    Storage.setValue(LATOPTION,$.Options_Dict[LATOPTION]);

    temp = Storage.getValue(LONOPTION);
    $.Options_Dict[LONOPTION] = (temp != null && temp instanceof Number) ? (temp) : 180; //last one is the default
    Storage.setValue(LONOPTION,$.Options_Dict[LONOPTION]);

    $.Options_Dict[GPSOPTION]= true;

    $.latlonOption_value= [$.Options_Dict[LATOPTION], $.Options_Dict[LONOPTION]]; 
}

var constellationAbbreviation_index = [0,0];

// Function to generate planet abbreviation and name
function getConstellationAbbreviation(which) {
       var const_json = [$.Rez.JsonData.constellation_1, $.Rez.JsonData.constellation_2];
    //loadPlanetsOpt();
        var cnsts = WatchUi.loadResource( const_json[which]) as Array;                
        
        var a = cnsts[constellationAbbreviation_index[which]];

        constellationAbbreviation_index[which] = (constellationAbbreviation_index[which] + 1)%cnsts.size();

        var b = cnsts[constellationAbbreviation_index[which]];
        
        constellationAbbreviation_index[which] = (constellationAbbreviation_index[which] + 1)%cnsts.size();

        return [a,b];            
}

/*
function getConstellationFull(abbr) {
    var const_json = [$.Rez.JsonData.constellation_1, $.Rez.JsonData.constellation_2];
    //loadPlanetsOpt();
    var res = "";
    for (var i = 0; i < const_json.size(); i++) {
        var cnsts = WatchUi.loadResource( const_json[i]) as Array;                
        for (var j = 1; j < cnsts.size(); j++) {
            deBug("cnsts1", [cnsts[j].substring(0,3), cnsts[j].substring(4,null)]);
            if (cnsts[j].substring(0,3).equals(abbr)) {
                deBug("@@!!!!!!!!!cnsts1", [cnsts[j].substring(0,3), cnsts[j].substring(4,null), abbr]);
                res = cnsts[j].substring(4,null);
                return res;
            }
        }
    }
    return res;
}*/
        

        

