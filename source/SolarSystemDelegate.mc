
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;


//! Handle input on initial view
class SolarSystemBaseDelegate extends WatchUi.BehaviorDelegate {
    private var _mainview as SolarSystemBaseApp?;
    //! Constructor
    public function initialize(view) {
        BehaviorDelegate.initialize();
        //System.println("delegate initl..");
        _mainview = view;
    }


    //! Handle the select button
    //! @return true if handled, false otherwise
    public function onSelect() as Boolean {

        //System.println("select button pressed");
        $.buttonPresses++;
        $.timeWasAdded=true;
        $.LORR_show_horizon_line = false;
        $.last_button_time_sec = $.time_now.value();
        //$.exiting_back_button_firstpress=false;
        if (buttonPresses == 1) {return true;} //1st buttonpress just gets out of intro titles

        $.started = !$.started;   
        return true;
    }

  

    function handleNextPrevious (type){
        //_view.nextSensor();
        //$.show_intvl = false;
        //_mainview.$.time_add_hrs -= _mainview.time_add_inc;
        //var mult = (type == :next) ? -1 : 1; //forward OR back dep on button

        started = true;

        //System.println("onNextPage..." + mult + " " + type);
        $.buttonPresses++; 
        $.last_button_time_sec = $.time_now.value();
  
        //$.exiting_back_button_firstpress=false;
        //$.change_mode_select_button_firstpress = false;
        
        $.run_oneTime = true; //in case we're stopped, it will run just once
        if (buttonPresses == 1) {return;} //1st buttonpress just gets out of intro titles

        if (type ==:next) {moveX +=10;}
        else {moveX -=10;}

      

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

    
}
