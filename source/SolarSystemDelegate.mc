
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

var select_pressed = false;
var back_pressed = false;
var zoom_level=0;
var incline_zero_deg as Lang.Float = 22.5;
var nextPrev_pressed = false;
var menu_pressed = false;

//! Handle input on initial view
class SolarSystemBaseDelegate extends WatchUi.BehaviorDelegate {
    //private var _mainview as SolarSystemBaseApp?;
    //! Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
        //System.println("delegate initl..");
        //_mainview = view;
    }


    //! Handle the select button
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {

        //System.println("select button pressed");
        $.buttonPresses++;
        //$.timeWasAdded=true;
        //$.LORR_show_horizon_line = false;
        //$.last_button_time_sec = $.time_now.value();
        //$.exiting_back_button_firstpress=false;
        //if (buttonPresses == 1) {return true;} //1st buttonpress just gets out of intro titles

        if ($.Options_Dict[COMPASSPOINT] != 0){
              //System.println("compass move + incline+");

                //$.zoom_level = 0;

                $.incline_zero_deg = 22.5; 
        } 
        

        //$.started = !$.started;  
        //$.compassStarted = !$.compassStarted; // toggle compass movement on/off
        $.started = true;
        solarSystemView_class.startAnimationTimer($.hz);
        select_pressed = true;
        $.time_changed = false;
        return true;
    }

        //! Handle the select button
    //! @return true if handled, false otherwise
    public function onBack() as Boolean {

        //System.println("select button pressed");
        $.buttonPresses++;
        //$.timeWasAdded=true;
        //$.LORR_show_horizon_line = false;
        //$.last_button_time_sec = $.time_now.value();
        //$.exiting_back_button_firstpress=false;
        //if (buttonPresses == 1) {return true;} //1st buttonpress just gets out of intro titles

        if ($.zoom_level == 0 || $.Options_Dict[COMPASSPOINT] > 0) { return false; } //when back to ZOOM 0 one more back exits

        //$.started = !$.started;   
        $.started = true;
        solarSystemView_class.startAnimationTimer($.hz);
        back_pressed = true;
        $.time_changed = false;
        return true;
    }

  

    function handleNextPrevious (type){
        //_view.nextSensor();
        //$.show_intvl = false;
        //_mainview.$.time_add_hrs -= _mainview.time_add_inc;
        //var mult = (type == :next) ? -1 : 1; //forward OR back dep on button

        //System.println("onNextPage..." + mult + " " + type);
        $.buttonPresses++; 
        $.last_button_time_sec = $.time_now.value();
  
        //$.exiting_back_button_firstpress=false;
        //$.change_mode_select_button_firstpress = false;
        
        $.run_oneTime = true; //in case we're stopped, it will run just once
        //if (buttonPresses == 1) {return;} //1st buttonpress just gets out of intro titles
        $.nextPrev_pressed = true;
        $.time_changed = false;

        //Moves left/right (non compass mode)
        //zooms in/out (compass mode)

        if ($.Options_Dict[COMPASSPOINT] != 0){
            if (type == :next) {
                if ($.zoom_level == 0) {$.zoom_level = 1;}
                else {$.zoom_level = 0;}
            }
            else { 
                //System.println("prev button0 + incline+" + $.incline_zero_deg);
                var add_amt = 22.5;
                if ($.zoom_level > 0) {add_amt = 2/3.0*22.5;}
                $.incline_zero_deg = mod($.incline_zero_deg + add_amt,112.5); 

                //System.println("prev button + incline+" + $.incline_zero_deg);
            } 
        
            
        } else {
            if (type ==:next) {moveAz_deg -=22.5;}
            else {moveAz_deg +=22.5;}                             
        }

        started = true;
        solarSystemView_class.startAnimationTimer($.hz);
    }
        

    

        //! Handle going to the next view
    //! @return true if handled, false otherwise
    public function onNextPage() as Boolean {
      handleNextPrevious (:next);   
      return true;
    }

    //! Handle going to the previous view
    //! @return true if handled, false otherwise
    public function onPreviousPage() as Boolean {
        //_view.previousSensor();
        //System.println("onPrevPage..." );
        handleNextPrevious (:previous);
       
        return true;
        
    }

     function onKey(keyEvent) {
        var keyvent =  keyEvent.getKey();
        System.println("GOT KEEY!!!!!!!!!: " + keyvent);         // e.g. KEY_MENU = 7

        if (keyvent == 7) {

            //menu_pressed = true;
            //$.started = true;
            //deBug("menu0", null);
            //if the device can handle MENU2...
            if ((WatchUi has :Menu2)) {
                //deBug("menu1", null);
                var menu = new $.StarsMenu();

                WatchUi.pushView(menu, new $.StarsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
                //deBug("menu2", null);
                return true;

            } else {  //For MENU2-less devices it is just a way to reset the view/escape zoom

                $.zoom_level = 0;
                $.menu_pressed = true;
                $.started = true;


            }

            WatchUi.requestUpdate();


            //return true;
        }
        return false;
        
        
    }

    
}
