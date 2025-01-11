
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


//! The app settings menu
class StarsMenu extends WatchUi.Menu2 {

    
    
    

    


    //! Constructor
    public function initialize() {
        //sssMenu_class = self;    

        
        //loadSettingsOpt();



       deBug("menu3", null);


        Menu2.initialize({:title=>WatchUi.loadResource($.Rez.Strings.settingstitle) as String});
       

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.constLines) as String, null, CONSTLINES, $.Options_Dict[CONSTLINES], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.constNames) as String, null, CONSTNAMES, $.Options_Dict[CONSTNAMES], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.allBolder) as String, null, ALLBOLDER, $.Options_Dict[ALLBOLDER], null));  

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.reverseColors) as String, null, REVERSECOLORS, $.Options_Dict[REVERSECOLORS], null));   

deBug("menu4", null);
           

        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_hrs.toString() + " hours", ADDHOURS, null));   
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_days.toString() + " days", ADDDAYS, null));   
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_months.toString() + " months", ADDMONTHS, null));   
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_years.toString() + " years", ADDYEARS, null));  
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_decades.toString() + " decades", ADDDECADES, null));
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String), time_add_centuries.toString() + " centuries", ADDCENTURIES, null)); 
        var dir = $.time_add_direction == 1 ? "Forward" : "Backward";
        Menu2.addItem(new WatchUi.MenuItem((WatchUi.loadResource($.Rez.Strings.timeDirection) as String), dir, TIMEDIRECTION, null)); 
        
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
            if (ret != null){
                          
                Storage.setValue(ret, menuItem.isEnabled());
                $.Options_Dict[ret] = menuItem.isEnabled();                        
                
            }            
           
        } else 

        if (menuItem instanceof MenuItem) {    
            

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
                
            } 

        }

    }

   
    function onBack() {

        
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
        
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
    

    }

        
}


function readStorageValues(){

    var temp = Storage.getValue(CONSTLINES);
    $.Options_Dict[CONSTLINES] = temp != null ? (temp == true) : true; //last one is the default
    Storage.setValue(CONSTLINES,$.Options_Dict[CONSTLINES]);
    
    temp = Storage.getValue(CONSTNAMES);
    $.Options_Dict[CONSTNAMES] = temp != null ? (temp == true) : true; //last one is the default
    Storage.setValue(CONSTNAMES,$.Options_Dict[CONSTNAMES]);

    temp = Storage.getValue(ALLBOLDER);
    $.Options_Dict[ALLBOLDER] = temp != null ? (temp == true) : false; //last one is the default
    Storage.setValue(ALLBOLDER,$.Options_Dict[ALLBOLDER]);

    temp = Storage.getValue(REVERSECOLORS);
    $.Options_Dict[REVERSECOLORS] = temp != null ? (temp == true) : false; //last one is the default
    Storage.setValue(REVERSECOLORS,$.Options_Dict[REVERSECOLORS]);
}