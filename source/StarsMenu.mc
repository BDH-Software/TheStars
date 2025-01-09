
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
    ADDHOURS,  
    ADDDAYS,
    ADDMONTHS,
    ADDYEARS,  
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


        Menu2.initialize({:title=>WatchUi.loadResource($.Rez.Strings.settingstitle) as String});
       

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.constLines) as String, null, CONSTLINES, $.Options_Dict[CONSTLINES], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.constNames) as String, null, CONSTNAMES, $.Options_Dict[CONSTNAMES], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.allBolder) as String, null, ALLBOLDER, $.Options_Dict[ALLBOLDER], null));  

        Menu2.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource($.Rez.Strings.reverseColors) as String, null, REVERSECOLORS, $.Options_Dict[REVERSECOLORS], null));   

        Menu2.addItem(new WatchUi.ToggleMenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_hrs.toString() + "hrs)", null, ADDHOURS, false, null));   
        Menu2.addItem(new WatchUi.ToggleMenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_hrs.toString() + "days)", null, ADDDAYS, false, null));   
        Menu2.addItem(new WatchUi.ToggleMenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_hrs.toString() + "mnths)", null, ADDMONTHS, false, null));   
        Menu2.addItem(new WatchUi.ToggleMenuItem((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_hrs.toString() + "yrs)", null, ADDYEARS, false, null));   

        
      

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
        
        if (menuItem instanceof ToggleMenuItem) {

            var ret = menuItem.getId() as String;

            if (ret != null && ret.equals(ADDHOURS)) {

                $.time_add_hrs = ($.time_add_hrs + 1)%24;
                changeTime = true;   
                menuItem.setLabel((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_hrs.toString() + "hrs)");             
                
            } else if (ret != null && ret.equals(ADDDAYS)) {

                $.time_add_days = ($.time_add_days + 1)%31;
                changeTime = true;   
                menuItem.setLabel((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_days.toString() + "days)");             
                
            } else if (ret != null && ret.equals(ADDMONTHS)) {

                $.time_add_months = ($.time_add_months + 1)%12;
                changeTime = true;   
                menuItem.setLabel((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_months.toString() + "mnths)");             
                
            
            } else if (ret != null && ret.equals(ADDYEARS)) {

                $.time_add_years = ($.time_add_years + 1);
                changeTime = true;   
                menuItem.setLabel((WatchUi.loadResource($.Rez.Strings.timeForward) as String) + time_add_years.toString() + "yrs)");             
                
            } else
            
            {
                          
                Storage.setValue(ret, menuItem.isEnabled());
                $.Options_Dict[ret] = menuItem.isEnabled();                        
                
            }            
           
        }

    }

   
    function onBack() {

        
        //$.cleanUpSettingsOpt();
        if (changeTime) {

            var addTime = Time.Gregorian.duration({:days => $.time_add_days + $.time_add_months*30, :hours => $.time_add_hrs, :years =>$.time_add_years});
            $.time_now = Time.now().add(addTime);
            $.now_info = Time.Gregorian.info($.time_now, Time.FORMAT_SHORT);

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