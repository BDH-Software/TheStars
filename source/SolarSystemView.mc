
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Position;
import Toybox.WatchUi;
import Toybox.Math;
import Toybox.System;
import Toybox.Application.Storage;

var _planetIcon as BitmapResource?;
//var newModeOrZoom = false;
//var speedWasChanged = false;
//var timeWasAdded = true; //helpful if this is true to make sure we DRAW SOMETHING at the start.
//var countWhenMode0Started  = 0;
//var drawPlanetCount =0;
//var count = 0;


//var the_rad = 0; //angles to rotate, theta & gamma
//var ga_rad = 0 ;
//var LORR_orient_horizon = true;
//var LORR_show_horizon_line = true;
//var LORR_oh_save_time_add_hrs = 0.158348;
//var LORR_oh_save_ga_rad = 25.158348;

var now, time_now, now_info;
var obliq_deg, moon_age_deg;
//var asteroidsRendered = false;

var save_local_animation_count;

//var ssbv_init_count_global = 0;

//var small_whh, /*full_whh,*/ zoomy_whh, whh0, whh1;
var moveAz = 0;
var moveY = 0;
var _updatePositionNeeded = true;
var _rereadGPSNeeded = true;

//! This view displays the position information
class SolarSystemBaseView extends WatchUi.View {

    
    private var _lines as Array<String>;
    private var _offscreenBuffer as BufferedBitmap?;    
    
    public var xc, yc, min_c, max_c, screenHeight, screenWidth, targetDc, screenShape, thisSys;
    private var ssbv_init_count;
    
    
    
    //private var page;
    
    //! Constructor
    public function initialize() {
        View.initialize();
        //page = pg;

        //if _global ever gets incremented we know there is anotherBaseView running & we should vamoosky

        //ssbv_init_count_global ++;        
        //ssbv_init_count = ssbv_init_count_global;
        //System.println("SsView init #"+ssbv_init_count);

        //speeds_index = 19; //inited in app.mc where the var is located
        view_mode = 0;
        Math.srand(start_time_sec);
        

        
        // Get the Initial POSITION value shown until we have the "real" position data from setPOosition
        //setPosition(); //Don't call setPosition() until the device is ready &
        //calls it via a callback (all set up in main app). Instead this INIT function will load
        //some semi, sensible data and thne setPOisition() will fill in the rest
        //later as available.  Also this & setPosition save position found
        //to the date store so initposition can use it next time.
        //UPDATE: can't do this until AFTER reading the storage values
        //But can't read storage values until this class is inited!
        //so we'll do it in BaseApp, after init of this class.
        //setInitPosition();

    

        _planetIcon = WatchUi.loadResource($.Rez.Drawables.Jupiter) as BitmapResource;
        
        //startAnimationTimer($.hz);


        //small_whh = toArray(WatchUi.loadResource($.Rez.Strings.small_whh_arr) as String,  "|", 0);
        //full_whh = toArray(WatchUi.loadResource($.Rez.Strings.full_whh_arr) as String,  "|", 0);
        //zoomy_whh = toArray(WatchUi.loadResource($.Rez.Strings.zoom_whh_arr) as String,  "|", 0);
        
        //whh0 = toArray(WatchUi.loadResource($.Rez.Strings.whh0) as String,  "|", 0);
        //whh1 = toArray(WatchUi.loadResource($.Rez.Strings.whh1) as String,  "|", 0);
        
  

        //helpOption = toArray(WatchUi.loadResource($.Rez.Strings.plan_abbr) as String,  "|", 0);
        //helpOption_size = helpOption.size();

        
        

        /*System.println("POs: " + planetsOption_values);
        System.println("POs0: " + whh0);
        System.println("POs1: " + whh1);
        System.println("POs1: " + small_whh);
        System.println("POs1: " + full_whh);
        System.println("POs1: " + zoomy_whh);*/
        //var myStats = System.getSystemStats();
        //System.println("Memory: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory );
        

    }

    //msg lines in an array to display & how long to display them
    //3 or 4 usually fit
    /*
    public function sendMessage (time_sec, msgs) {
        // /2.0 cuts display timein half, need a better solution involving actual
        //clock than guessing about animation  frequency
        //message_until = $.animation_count + time_sec * hz/2.0;
        message_until = time_now.value() + time_sec;
        //message = [msg1, msg2, msg3, msg4, $.animation_count + time_sec * hz/2.0 ];
        message = [message_until];
        //System.println("sm: " + time_sec + " "+ message +  " : " + msgs);
        message = message.addAll(msgs);        
        //System.println("sm2: " + time_sec + " "+ message +  " : " + msgs);
        
    }
    */

    var local_animation_count = 0;
    var gps_wait = 0;

    function animationTimerCallback() as Void {
            

            //deBug("timer:", [started, $.animation_count]);

           //if ($.view_modes[$.view_mode] == 0 ) {
           // started = true;
           //}
           //if (local_animation_count < save_local_animation_count )
            //  {killExtraBaseView();}
            //local_animation_count++;
            //save_local_animation_count = local_animation_count;
           $.animation_count ++;
           animSinceModeChange ++;

           /*if ($.started
                && ($.view_mode>0) ) {
                $.time_add_hrs += $.speeds[$.speeds_index];
              
            }*/

            if (!gps_read && gps_wait < 20) {
                gps_wait ++;
                deBug("Waiting for gps...");
                return;

            } else if (!$.hippconst_finished ) {
                started = false;
                processStars();
                WatchUi.requestUpdate();
            } else {

                WatchUi.requestUpdate();
            }
           
            //WatchUi.requestUpdate();
            // } else if ($.view_modes[$.view_mode] == 0) { //view_mode==0, we always request the update & let it figure it out
             //   WatchUi.requestUpdate();
             //}
             //} else if (mod($.animation_count,$.hz)==0) {
                //update screen #0 at 1 $.hz, much like a watchface...
                //WatchUi.requestUpdate();
                
             //}
             
            
           //Allow msgs etc when screen is stopped, but just @ a lower $.hz 
           //} else if ($.animation_count%3 == 0) {
           //  WatchUi.requestUpdate();
           //}
           //System.println("animationTimer: " + $.animation_count + " started: " + $.started + $.speedWasChanged +$.timeWasAdded);
    }


    var animationTimer=null;

    public function startAnimationTimer(hertz){

        //var myStats = System.getSystemStats();
        //System.println("Memory: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory );
        //System.exit();

        //var now2 = System.getClockTime();
        //System.println ("AnimTimer:" 
        //    +  now2.hour.format("%02d") + ":" +
        //    now2.min.format("%02d") + ":" +
        //    now2.sec.format("%02d"));

        if (animationTimer != null) {
            try {
                animationTimer.stop();
                animationTimer = null;
            } catch (e) {

            }

        }

        WatchUi.requestUpdate(); //sometimes screen doesn't show when returning from settings etc, trying to solve

        animationTimer= new Timer.Timer();
        
        animationTimer.start(method(:animationTimerCallback), 1000/hertz, true);
        //$.started = true;
        //if ($.reset_date_stop) {$.started=false;}
    }

    public function stopAnimationTimer(){

        //ystem.println ("Stop Animation Timer at " 
        //    +  $.now.hour.format("%02d") + ":" +
        //    $.now.min.format("%02d") + ":" +
        //    $.now.sec.format("%02d"));

        if (animationTimer != null) {
            try {
                animationTimer.stop();
                animationTimer = null;
            } catch (e) {

            }

        }
    }

    //Two views have been created, somehow, & they are competing.   Kill the newest one.
    public function exitExtraBaseView(){

        stopAnimationTimer();
        self=null;
    }


    //! Load your resources here
    //! @param dc Device context
    public function onLayout(dc as Dc) as Void {
        /*System.println ("onLayout at " 
            +  $.now.hour.format("%02d") + ":" +
            $.now.min.format("%02d") + ":" +
            $.now.sec.format("%02d"));
            */

        thisSys = System.getDeviceSettings();
        
        screenHeight = dc.getHeight();
        screenWidth = dc.getWidth();

        xc = dc.getWidth() / 2;
        yc = dc.getHeight() / 2;

        min_c  = (xc < yc) ? xc : yc;
        max_c = (xc > yc) ? xc : yc;
        screenShape = thisSys.screenShape;

        startAnimationTimer($.hz);
        thisSys = null;        
    
    }

    //! Handle view being hidden
    public function onHide() as Void {
        //System.println ("onHide:" 
        //    +  $.now.hour.format("%02d") + ":" +
        //    $.now.min.format("%02d") + ":" +
        //    $.now.sec.format("%02d"));
        $.save_started = $.started;
        $.started = false;
        stopAnimationTimer();
        //pp=null;
        //pp_sun = null;
        //kys =  null;
        //keys = null;
        //srs = null;
        //sunrise_events  = null;
        //whh = null;
        //whh_sun = null;
        //g = null;
        //spots_rect = null;
        

    }

    var onshow = false;

    //! Restore the state of the app and prepare the view to be shown
    public function onShow() as Void {
        //System.println ("onShow:" 
        //    +  $.now.hour.format("%02d") + ":" +
        //    $.now.min.format("%02d") + ":" +
        //    $.now.sec.format("%02d"));
        //$.started = $.save_started != null ? $.save_started : true;
        //if ($.reset_date_stop) {$.started = false;} // after a Date Reset we STOP at that moment until user wants to start.
        //timeWasAdded = true;
        //settings_view = null;
        //settings_delegate = null;
        started = true;
        onshow = true; //forces dc.clear / redraw
        startAnimationTimer($.hz);
        WatchUi.requestUpdate();

    }

    /*

    var offScreenBuffer_started = false;

    function startOffScreenBuffer (dc){ 
        if (offScreenBuffer_started) {return;}

        var offscreenBufferOptions = {
                    :width=>dc.getWidth(),
                    :height=>dc.getHeight(),
                    :palette=> [
                        //Graphics.COLOR_DK_GREEN,
                        //Graphics.COLOR_GREEN,
                                            
                        Graphics.COLOR_BLACK,
                        Graphics.COLOR_WHITE,
    
                    ]
                };

            if (Graphics has :createBufferedBitmap) {
                // get() used to return resource as Graphics.BufferedBitmap
                _offscreenBuffer = Graphics.createBufferedBitmap(offscreenBufferOptions).get() as BufferedBitmap;
            } else if (Graphics has :BufferedBitmap) { // If this device supports BufferedBitmap, allocate the buffers we use for drawing
                // Allocate a full screen size buffer with a palette of only 4 colors to draw
                // the background image of the watchface.  This is used to facilitate blanking
                // the second hand during partial updates of the display
                _offscreenBuffer = new Graphics.BufferedBitmap(offscreenBufferOptions);

            } else {
                _offscreenBuffer = null;
                
            }
            /*
            if (null != _offscreenBuffer) {
                // If we have an offscreen buffer that we are using to draw the background,
                // set the draw context of that buffer as our target.
                targetDc = _offscreenBuffer.getDc();
                
            } else {
                targetDc = dc;
                
            }
            */
            /*
            offScreenBuffer_started = true;
    }

    function stopOffScreenBuffer(){
        _offscreenBuffer = null;
        targetDc = null;
        offScreenBuffer_started = false;
        asteroidsRendered = false;

    }
    */

    //hr are in hours, so *15 to get degrees
    //drawArc start at 3'oclock & goes CCW in degrees
    //whereas hrs start at midnight (6'oclock position) and proceed clockwise.  Thus 270 - hr*15.
    public function drawARC (dc, hr1, hr2, xc, yc, r, width, color) {
        
        if (hr1 == null || hr2 == null) {return false;}
        dc.setPenWidth(width);
        if (color != null) {dc.setColor(color, Graphics.COLOR_TRANSPARENT);}
        dc.drawArc(xc, yc, r, Graphics.ARC_CLOCKWISE, 270.0 - hr1 * 15.0, 270.0 - hr2 *15.0);   
        //deBug("drawArc", [270.0 - hr1 * 15.0, 270.0 - hr2 *15.0, hr1, hr2]);
        return true;
    }
    


    //dashed line 
    //Note len_line can be ZERO - in that case it just draws a single pixel/dot for each "dash"
    public function drawDashedLine (myDc,x1, y1, x2, y2, len_line, len_skip, width, color) {

        if (x1<-screenWidth * .3 || x1>screenWidth * 1.3 ||
         x2<-screenWidth * .3 || x2>screenWidth * 1.3 ||
         y1<-screenHeight * .3 || y1>screenHeight * 1.3 ||
        y2<-screenHeight * .3 || y2>screenHeight * 1.3) {
            return;
        }
                
        myDc.setPenWidth(width);
        if (color != null) {myDc.setColor(color, Graphics.COLOR_TRANSPARENT);}

        var x_diff = x2 - x1;
        var y_diff = y2 - y1;
        var length = Math.round(Math.sqrt(x_diff * x_diff + y_diff * y_diff));
        if (length==0) {length = 1;}
        
        for (var i = 0; i < length; i += len_line + len_skip) {
            var x = x1 + (x_diff * i / length);
            var y = y1 + (y_diff * i / length);
            if (len_line < 1) {
                myDc.drawPoint(x,y);
            } else {                
                var x_2 = x1 + (x_diff * (i + len_line) / length);
                var y_2 = y1 + (y_diff * (i + len_line) / length);
                myDc.drawLine(x,y,x_2,y_2);
            }
        }
    }
    /*
    //Triangle pointing in the direction  dir_x, dir_y to x1,y1, pointing outwards from x1,y1
    //coord = [dir_x, dir_y, x1, y1]
    public function drawTrianglePointer (myDc, coord, length, base_width, line_width, color, outline, pointer_line) {
                
        myDc.setPenWidth(line_width);
        if (color != null) {myDc.setColor(color, Graphics.COLOR_TRANSPARENT);}

        var x_diff = coord[2] - coord[0];
        var y_diff = coord[3] - coord[1];
        var dir_length = Math.round(Math.sqrt(x_diff * x_diff + y_diff * y_diff));
        var x2 = coord[2] + (x_diff * length / dir_length);
        var y2 = coord[3] + (y_diff * length / dir_length);
        var y3 = coord[3] + (x_diff * 0.5*base_width / dir_length) ;
        var x3 = coord[2] - (y_diff * 0.5*base_width / dir_length);
        var y4 = coord[3] - (x_diff * 0.5*base_width / dir_length);
        var x4 = coord[2] + (y_diff * 0.5*base_width / dir_length);

        if (pointer_line) {
            myDc.drawLine(coord[2], coord[3], coord[0], coord[1]);
        }
        if (outline) {
            myDc.drawLine(x4,y4,x3,y3);
            myDc.drawLine(x3,y3, x2,y2);
            myDc.drawLine(x2,y2,x4,y4);
        } else {
            myDc.fillPolygon([[x4,y4],[x3,y3],[x2,y2],[x4,y4]]);
        }
        
        
    }
    */

/*
    public function doUpdate(dc, move){
        switch($.view_mode){
            case (0): //manual ecliptic (& follows clock time)
                /*stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                $.timeWasAdded = false;
                break;*/
                /*
            case (1):  //slow-moving animated ecliptic
                //stopOffScreenBuffer();
                starField(dc);
                //largeEcliptic(dc, 0);
                $.timeWasAdded = false;
                //if (buttonPresses<1){started = false;}
                //if ($.started) {WatchUi.requestUpdate();}
                break;
                */
            /*case (2):  //animation moving at one frame/day; sun frozen
                stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                
                //if ($.started) {WatchUi.requestUpdate();}
                break;    
            case(3): //top view of center 4 planets
            case (4): //oblique
                //time_add_inc = 24*3;
                
                startOffScreenBuffer(dc);
                largeOrrery(dc, 0);
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                //if ($.started) {WatchUi.requestUpdate();}
                break;
            case(5): //top view of main planets
            case(6): //oblique view of main planets
               
                startOffScreenBuffer(dc);
                largeOrrery(dc, 1);
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                //if ($.started) {WatchUi.requestUpdate();}

                break;
            
            case(7):  //top view taking in some trans-neptunian objects
            case(8):  //top view taking in some trans-neptunian objects
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                
                startOffScreenBuffer(dc);
                largeOrrery(dc, 2);
                //if ($.started) {WatchUi.requestUpdate();}

                break;
            default:
                //if (move) {$.time_add_hrs += speeds[speeds_index];}
                stopOffScreenBuffer();
                largeEcliptic(dc, 0);
                
                //if ($.started) {WatchUi.requestUpdate();}
                */
     /*       


        }
    }
    */

    function titlePage(dc as Dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();
        //dc.setPenColor(0, 0, 0);
        
        
        var font = Graphics.FONT_SYSTEM_LARGE;
        var dateFont = Graphics.FONT_SYSTEM_MEDIUM;
        var textHeight = dc.getFontHeight(font);
        dc.drawText(
            xc, 
            yc - textHeight,
            font,
            "THE",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(xc, yc,font,"STARS",Graphics.TEXT_JUSTIFY_CENTER);

        if (!$.goodGPS)
        {     dc.drawText(
                xc / 4.0, 
                yc -2 *textHeight,
                dateFont, 
                "(getting GPS position)",
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
        

        if ($.time_changed) {


            //deBug("tn", [$.time_now, $.time_now instanceof Time.Moment]);
            
            var med_info = Time.Gregorian.info($.time_now, Time.FORMAT_MEDIUM);

            //var t_now = new Time.Moment($.time_now.value());

            //var local = Time.localMoment(where, $.time_now);
            //var local = Time.localMoment(where, t_now.value());

            //var local_info = Time.Gregorian.info(local, Time.FORMAT_MEDIUM);

            var mySettings = System.getDeviceSettings();
            var is24Hr = mySettings.is24Hour;

            
            var hr = $.now_info.hour.format("%02d");
            var ampm = "";

            if (!is24Hr) {
                 hr = $.now_info.hour%12;
                    if (hr == 0) {hr = 12;}
                    ampm = "am";
                    if ($.now_info.hour >=12) {
                        ampm = "pm";
                    }
            }

            var ti = hr +":" + $.now_info.min.format("%02d") + ampm;

            dc.drawText(
                xc, 
                yc + 2*textHeight,
                dateFont, 
                ti, 
                Graphics.TEXT_JUSTIFY_CENTER
            );

            //dc.drawText(xc, yc + 1*textHeight,font, local_info.day.format("%02d") + " " + local_info.month + " " + local_info.year,Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(
                xc, 
                yc + 1*textHeight,
                dateFont, 
                $.now_info.day.format("%02d") + " " + med_info.month + " " + $.now_info.year,Graphics.TEXT_JUSTIFY_CENTER
            );
        }
        //dc.drawText(0, 0, "THE");
        //dc.drawText(0, 0, "STARS");


    }

    //! Update the view
    //! @param dc Device context    
    var save_count =-10;
    var stopping_completed = true;
    var textDisplay_count = 0;
    var old_mode = -1;
    
    var planetRand = 0;
    
    var ranvar = 0;
    var showingTitle = false;
    var titleShows = 0;
    
    public function onUpdate(dc as Dc) as Void {
        



        //$.count++;

        

        //$.now = System.getClockTime(); //for testing

        if ($.time_just_changed || $.pos_just_changed){
            processStars_init();
            processStars();
            $.time_just_changed = false;
            $.pos_just_changed = false;
            return;
        }

        if (!$.hippconst_finished || $.time_changed) {
            showingTitle = true;
            titleShows ++;
            if (titleShows >60 && $.hippconst_finished && $.time_changed) {$.time_changed = false;} 
            titlePage(dc);
            return;
        }
        if (showingTitle) {

            showingTitle = false;
            $.select_pressed = false;
            $.back_pressed = false;
            $.nextPrev_pressed = false;
            titleShows = 0;
            return; 
            //first button press gets out of Title screen
        }
        
       
       /* if (!started) {
            tally=0;
            tally2=0;
            return;
            } */
        starField(dc);
        return;
    }
    
    

    var def_size = 175.0 /2;
    var b_size = 2.0;
    var jup_size = 4.0;
    var min_size = 1.0;
    var fillcol= Graphics.COLOR_BLACK;
    //var col = Graphics.COLOR_WHITE;

    public function drawPlanet(dc, key, xyr, base_size, ang_rad, type, big_small, small_whh) {
        //System.println("key: " + key);
        var size;

        //$.drawPlanetCount++;
        var x = xyr[0];
        var y = xyr[1];
        //var z = xyr[2];
        //var radius = xyr[3];

        var col = starColor;
        fillcol = starBackgroundColor;
        b_size = base_size/def_size*min_c;
        min_size = 3.0/def_size*min_c;
        var max_size = 1.7*min_size;
        size = b_size;

        
        if (type == :orrery) { size = b_size/32.0;}
        if (key.equals("Sun")) {
            size = 8*b_size;
            if (type == :orrery) {size = 2*b_size;}
            col = 0xf7ef05;
            fillcol = 0xf7ef05;
            //if (type == :orrery) { size = b_size;}
            
        }
        switch (key) {
            case "Mercury":
                size = b_size *jup_size*0.03488721374f;
                col = 0x8f8aae;
                fillcol = 0x70708f;
                break;
            case "Venus":
                size =b_size*jup_size * 0.08655290298f;
                //col = 0xffff88;
                //fillcol = 0x838370;
                col = 0xffff88;
                fillcol = 0xeeee88;
                break;

            case "Mars":
                size =b_size*jup_size * 0.04847591938f;
                col = 0xff9a8e;
                fillcol = 0x9f4a5e;

                break;
            case "Saturn":
                size =b_size *jup_size * 0.832944744f;
                col = 0x947ec2;
                break;
            case "Jupiter":
                size =b_size *jup_size;
                col = 0xcf9c63;
                break;
            case "Neptune":
                size =b_size *jup_size * 0.3521906424f;
                col = Graphics.COLOR_BLUE;
                fillcol = col;
                break;
            case "Uranus":
                size =b_size *jup_size * 0.3627755289f;
                col = Graphics.COLOR_BLUE;
                fillcol = Graphics.COLOR_GREEN;
                break;
         
            case "Moon":
                size =b_size *jup_size * 0.09113015119f; //same as EARTH here, we adjust to true size rel. to earth below
                col = 0xe0e0e0;        
                fillcol = 0x171f25;                                
                break;                
                
             case "Pluto":
                size =b_size *jup_size * 0.016993034f; 
                col = starColor;
                fillcol = Graphics.COLOR_RED;
                break;   
                     
        }
        
        //to allow earth, moon, venus, mars to be shown more @ real size in 
        //this view
        /*
        var preserve_size = false;
        if (type == :orrery && big_small == 0 && !key.equals("Sun")) {size = 1.5* size; min_size = min_size/2.0; preserve_size = true;}

        else if (type == :orrery && (big_small ==1) && planetsOption_value ==2 && !key.equals("Sun")) {size = 1.5* size; min_size = min_size/2.0; preserve_size = true;}

        //When look@ dwarf planets only, allow THOSE TO set the size value
        else if (type == :orrery && (big_small ==2) && planetsOption_value ==2 && !key.equals("Sun")) {size = 12*size;min_size = min_size/2.0; preserve_size = true;}
        
        else if (type == :orrery &&  (big_small ==2) && planetsOption_value ==1 && !key.equals("Sun")) {size = size/8.0;min_size = min_size/2.0; preserve_size = true;}
        
        else if (type == :orrery &&  (big_small ==2) && !key.equals("Sun")) {size = size/4.0;min_size = min_size/1.5; preserve_size = true;}

        else if (type == :orrery &&  (big_small ==1) && planetsOption_value ==1 && !key.equals("Sun")) {size = size/8.0;min_size = min_size/2.0; preserve_size = true;}

        else if (type == :orrery &&  (big_small ==1) && !key.equals("Sun")) {size = size/6.0;min_size = min_size/2.0; preserve_size = true;}


        */

        /*

        var correction =  1;
        if (type == :orrery) { 
            if (!preserve_size) {size = Math.sqrt(size);}

            if (min_c > 120) { //for higher res watches where things tend to come out tiny
                //trying to make the largest things about as large as half the letter's height
             correction = 0.3 * textHeight/ Math.sqrt(8*b_size);
             //System.println("orrery correction " + correction);
             if (correction< 1) {correction=1;}
             if (correction< 1.5) {correction=1.5;}             
              size = size * correction;
            }
            //if (key.equals("Moon")){size /= 3.667;} //real-life factor
            
            }
        else if (type == :ecliptic) {
            if (key.equals("Moon")){size =  8*b_size;} //same as sun
            size = Math.sqrt(Math.sqrt(Math.sqrt(size))) * 5;
            
            if (min_c > 120) { //for higher res watches where things tend to come out tiny
                correction = 0.3 * textHeight/    Math.sqrt(Math.sqrt(Math.sqrt(size))) / 5;
                //System.println("ecliptic correction " + correction);
                if (correction< 1) {correction=1;}
                if (correction< 1.5) {correction=1.5;}             
                size = size * correction;
            }
        }

        */

        if (size < min_size) { size = min_size; }
        if (size > max_size) { size = max_size; }

        //if (type == :orrery && big_small == 1 && key.equals("Sun")) {size = size/2.0;}
        //if (type == :orrery && big_small == 2 && key.equals("Sun")) {size = size/4.0;}
        
        /* {
            if (key.equals("Moon"))
            { size = min_size/2.0; }
            
            else 
        }*/
        //System.println("size " + key + " " + size);
        /*
        if (type == :orrery && (key.equals("Moon"))) {
            if (big_small == 0)  {
                //we set moon's size equal to earth above
                //now we adj the end product to get
                //the right proportions (with no MIN for moon as for all  other objects)
                size = size/3.671; //EXACT for orrery mode 1

            } else {                            
                size = size/3.2; //a little less exact for modes 2,3
                
            }
            if (size<0.5) {size=0.5;} //keep it from completely disappearing no matter what
        }
        */
        //System.println("size2 " + key + " " + size + " " + min_size);

        /*

        size *= planetSizeFactor; //factor from settings

        if (key.find("Ecliptic") != null) {
            var trisize = min_c/15.0*2.25;
            var tribase = trisize/3/2.25;
            size = min_c/60.0;
            //var fill = false;
            
            if (key.equals("Ecliptic0") || key.equals("Ecliptic180") ) {
                //fillcol = Graphics.COLOR_DK_GRAY;
                //fill = true;
                tribase = 1.5*tribase;
                if (key.equals("Ecliptic0")) {tribase *= 1.8; trisize *= 1.15;}
            }

            
            drawTrianglePointer (dc, [xc, yc, x, y,], trisize, tribase, 1, Graphics.COLOR_WHITE, false, false);

            
        } //solstice & equinox points, small circles

        */
            

        //var pers = 1;
        
        /*
        var max_p = 1.0;
        var pers =  z/max_c/2.0 + 0.5;            //ranges 0-1
        pers = ( 0.5  + pers)/1.5;  //between 2-3/2.5, when z=0, pers = 1;
        if (pers> max_p) {pers = max_p; }
        if (pers < 0.05   ) {pers = 0.05;}
        */

        /*
        //Handle perspective for orrery modes
        if (type == :orrery) {
            if (z>1.5 * max_c) {return;} //this one is "behind" us, don't draw it
            if (size > radius * .8 && !key.equals("Sun")) {return;} 
            if (z>max_c) {z= max_c;}
            var pers = 2*max_c / (2.0* max_c - z);

            if (pers < 0.05   ) {pers = 0.05;}

            size *= pers;
        }

        */

        if (zoom_level>0) {size*=1.4;}
        if ($.Options_Dict[ALLBOLDER]) {size*=1.5;}

        var pen = Math.round(size/10.0).toNumber();
        if (pen<1) {pen=1;}
        dc.setPenWidth(pen);
        dc.setColor(fillcol, starBackgroundColor);        
        if (size>1) {dc.fillCircle(x, y, size);}
        dc.setColor(col, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(x, y, size);
        
        switch (key) {
            case "Sun" :
                //dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.setColor(0xf7ef05, Graphics.COLOR_TRANSPARENT);
                //if (type == :orrery) {break;}
                if (size<10) {size = 10;}
                
                dc.fillCircle(x, y, size);
                for (var i = 0; i< 2*Math.PI; i += 2*Math.PI/8.0) {
                    var r1 = size *1.2;
                    var r2 = size * 1.5;
                    var x1 = x + Math.cos (i) * r1;
                    var y1 = y + Math.sin (i) * r1;
                    var x2 = x + Math.cos (i) * r2;
                    var y2 = y + Math.sin (i) * r2;
                    dc.drawLine(x1,y1,x2,y2);

                }
                break;
            case "Mercury" :                
                dc.setColor(0xffffff, Graphics.COLOR_TRANSPARENT);        
                drawARC (dc, 17, 7, x, y - size/2.0,size/2.25, pen, null);
                drawARC (dc, 0, 24, x, y + size/3.0,size/2.25, pen, null);
                break;
            case "Venus":
                //dc.fillCircle(x, y, size);
                //dc.setColor(0x737348, Graphics.COLOR_TRANSPARENT);        
                //drawARC (dc, 17, 7, x, y - size/2.5,size/2.3, 1, null);
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT); 
                drawARC (dc, 0, 24, x, y - size/5.0,size/2.2, pen, null);
                dc.drawLine (x, y - size/5.0 + size/2.2, x, y+3.8*size/5.0);

                dc.drawLine (x-size/5.0, y + size/2.0, x+size/5.0, y + size/2.0);

                //dc.fillCircle(x, y,size/4);
                break;
            case "Mars":
                //dc.fillCircle(x, y, size);
                //dc.setColor(0x734348, Graphics.COLOR_TRANSPARENT);        
                      var x1 = x - size/12.0;
                var y1 = y + size/12.0;
                //drawARC (dc, 17, 7, x, y - size/2.5,size/2.3, 1, null);
                drawARC (dc, 0, 24, x1, y1 ,size/2.0, pen, null);
          
                dc.drawLine (x1 + size/4.0 + size/18.0 , y1 - size/2.0 - size/18.00,x1 + size/2.0+ size/18.0, y1 - size/2.0 - size/18.0);
                dc.drawLine (x1 + size/2.0 + size/18.0, y1 - size/4.0- size/18.0,x1 + size/2.0+ size/18.0, y1 - size/2.0 - size/18.0);

                //dc.drawLine (x-size/5.0, y + size/2.0, x+size/5.0, y + size/2.0);

                //dc.fillCircle(x, y,size/4);
                break;    
            case "Jupiter":
                dc.drawLine(x-size*.968+pen/3.0, y-size/4, x+size*.968-pen/3.0, y-size/4);
                dc.drawLine(x-size*.968+pen/3.0, y+size/4, x+size*.968-pen/3.0, y+size/4);
                break;
            case "Saturn":
                dc.drawLine(x-size*1.7, y+size/3, x+size*1.7, y-size/3);
                //dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x-size*1.6, y+size*.37 , x+size*1.6, y-size*.21);
                //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.drawLine(x-size*1.5, y+size*.41 , x+size*1.5, y-size*.15);
                //dc.drawLine(x-size, y+size/4, x+size, y+size/4);
                break;
            case "Neptune" :
                dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);   
                y1 = y + size/12.0;             //
                dc.drawLine(x, y1+3*size/5.5, x, y1-3*size/4);
                drawARC (dc, 18, 6, x, y1 - 1*size/2.0, size*2/3.0, pen, null);
                break;
            case "Uranus" :
                
                //dc.drawLine(x, y+4*size/5, x, y-4*size/5);
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);                //
                dc.fillCircle (x, y, size/3);  
                if (size>4) {drawARC (dc, 0, 24, x, y,3*size/4.0, pen, null);}
                break;
             case "Pluto" :
                
                //dc.drawLine(x, y+4*size/5, x, y-4*size/5);
                dc.drawLine(x-size/7.0, y+2*size/4, x-size/7.0, y-2*size/4);                      
                //dc.drawLine(x-size/3.0, y+3*size/4, x-size/3.0, y-3*size/4);                      
                drawARC (dc, 10, 27, x+size/10.0, y-size/6,size/2.8, pen, null);
                break;
           
            case "Moon" :  
                    if (size<8) {size = 8;}

                    if (moon_age_deg >= 94 && moon_age_deg < 175) {
                         dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(moon_age_deg - 90 )/9.48683, size);
                         //dc.fillEllipse(x, y, size * (moon_age_deg - 90 )/90.0, size);
                    }

                    if (moon_age_deg >= 185 && moon_age_deg < 266) {
                         dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(270-moon_age_deg)/9.48683, size);
                         //dc.fillEllipse(x, y, size * (270-moon_age_deg)/90.0, size);
                    }

                    if (moon_age_deg >= 358 || moon_age_deg <= 2) { //NEW moon

                            dc.setColor(0x171f25, Graphics.COLOR_TRANSPARENT);                //0x171f25
                            dc.fillCircle(x, y, size);
                            //dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            //dc.drawCircle(x, y, size);
                    }

                    else if (moon_age_deg > 2 && moon_age_deg <= 175) { //1st quarter
                            //dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);                
                            //dc.drawCircle(x, y, size);
                            dc.setClip (x, y-size,size+1, size*2);                        
                            dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            dc.fillCircle(x, y, size);
                            dc.clearClip();
                            

                    }
                    else if (moon_age_deg > 175 && moon_age_deg <= 185) { //FULL
                            
                            dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            
                            //dc.drawCircle(x, y, size);              
                            
                            dc.fillCircle(x, y, size);
                    }
                    else if (moon_age_deg > 185 && moon_age_deg < 358) { //Last quarter
                            
                            //dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            //dc.drawCircle(x, y, size);
                            
                            dc.setClip (x-size, y-size,size, size*2+2);
                            dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                            dc.fillCircle(x, y, size);
                            dc.clearClip();
                    }
                    //black OR white ellipse to blank out or add some/all of the half moon to show
                    //phases in between quarters
                    //This can be refined more to show exact lit percentages, if desireds.
                    if (moon_age_deg > 0 && moon_age_deg < 86){
                         dc.setColor(0x171f25, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(90-moon_age_deg)/9.48683, size);
                    }

                    else if (moon_age_deg > 274 && moon_age_deg < 360){
                         dc.setColor(0x171f25, Graphics.COLOR_TRANSPARENT);                //0x171f25
                         dc.fillEllipse(x, y, size * Math.sqrt(moon_age_deg-270)/9.48683, size);
                    }

                    //white ellipse to add to the half moon after 1st quarter

                    
                    //draw the full circle last so it always looks like a full round circle w/ phases
                    dc.setColor(0xf0f9ff, Graphics.COLOR_TRANSPARENT);  
                    dc.drawCircle(x, y, size);
                    //deBug("Moon!", moon_age_deg);
                    
                
                break;
                    
        }

        //If it might be behind the sun, draw the Sun on top...
        /*if (!key.equals("Sun") && radius<3*size && z<0) {
            drawPlanet(dc, "Sun", [0, 0, 0, 0], base_size, ang_rad, type, big_small, small_whh);

        }*/
        /*
        if (key.equals("Sun") ) {
            
            //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        } else  if (key.equals("Venus")) {
            
            //dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);        
        }
        */
        /*
        var drawThis=false;
        if ($.Options_Dict[labelDisplayOption_enum] != 1){

            var mlt = 4;
            if ($.Options_Dict[labelDisplayOption_enum]==3) {mlt = 8;}
            else if ($.Options_Dict[labelDisplayOption_enum]==0 ) {mlt = 1;}
            else if ($.Options_Dict[labelDisplayOption_enum]==4 ) {
                
                    //sparkly labels effect/random 1/4 of the planets @ any time
                  drawThis = (planetRand + $.drawPlanetCount)%pp.size()<pp.size()/8;
                  mlt = 20;
                
                }
            //System.println ("1328: " + " " + textDisplay_count + " " + mlt + " " + $.hz + " " + drawThis);
            var hez = 5;
            var mlt2 = 1;
            if ($.hz == null ) {hez = 5;} 
            else { hez = $.hz * 4; mlt2 = 4;}

            ///########### SHOW NAME ABBREVIATION ##########################
            if ((textDisplay_count * mlt2) % (mlt*hez).toNumber() < hez || drawThis) {
            
               /*
               if (type == :ecliptic) {
                    if (!key.equals("Sun") && key.find("Eclipt")==null)  {
                        sub = findSpot(-pp[key][0]+sid);
                        mult = 0.8 - (.23 * sub);
                        x2 = mult*r* Math.cos(ang_rad) + xc;
                        y2 = mult* r* Math.sin(ang_rad) + yc;

                        dc.setColor(col, Graphics.COLOR_TRANSPARENT);        
                        dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER + Graphics.TEXT_JUSTIFY_CENTER);
                        sub = null;
                        //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
                    }
                } else if (type == :orrery) {
                    
                    //var drawSmall = big_small==0  
                        //|| (radius > 4*b_size); //4*b_size is size of sun as drawn in orrery view
                    //|| (big_small==1 && (small_whh.indexOf(key)==-1 || orrZoomOption_values[$.Options_Dict["orrZoomOption"]] >= 4))
                    //|| (big_small==2 && ( small_whh.indexOf(key)==-1 || orrZoomOption_values[$.Options_Dict["orrZoomOption"]] >= 8));
                    
                    if (!key.equals("Sun") && !key.equals("Moon") )  {
                        sub = findSpotRect(x,y);
                        //mult = 2 + sub;
                        x2 = sub[0];
                        y2 = sub[1];
                        dc.setColor(col, Graphics.COLOR_TRANSPARENT);        
                        dc.drawText(x2, y2, Graphics.FONT_TINY, key.substring(0,2), Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_CENTER);
                        sub = null;
                        //drawAngledText(x as Lang.Numeric, y as Lang.Numeric, font as Graphics.VectorFont, text as Lang.String, justification as Graphics.TextJustification or Lang.Number, angle as Lang.Numeric) as Void
                    }
                    */



                //}
                /*
            }
        }
        */
    }


    const byteDeg = 360f/256f;

    public function XY (az, alt) {
            var x = Math.cos(Math.toRadians(az+addAz)) * (90.0 - alt); 
            var y = Math.sin (Math.toRadians(az+addAz)) * (90.0 - alt);

            y = (y + addy) * screenHeight / sizey ;
            x = xc - x * screenWidth /sizex;
            return [x, y];    
    }
    //for purposes of Horizon, we need to not squeeze X & Y differently; it's top 
    //to bottom of the screenHeight.
    //Also this is an approximation now, probably should be like a ellipse or sojmething
    //of we are scaling X & Y differently.
    public function XY_nosqueeze (az, alt) {
            var x = Math.cos(Math.toRadians(az+addAz)) * (90.0 - alt); 
            var y = Math.sin (Math.toRadians(az+addAz)) * (90.0 - alt);

            y = (y + addy) * screenHeight / sizey ;
            x = xc - x * screenHeight /sizey;
            return [x, y];

    }


    public function drawHorizon(dc){
        var xy = XY_nosqueeze(0, 90);
        var xy2 = XY_nosqueeze(0, 0);
        //dc.setColor(0xe1a75c,starBackgroundColor);
        //dc.drawCircle(xy[0], xy[1],dist (xy, xy2));
        drawARC (dc, 0, 24.05, xy[0], xy[1],dist (xy, xy2) + 1, 3, 0xe1a75c);

    }

    /*
    public function drawStar(dc, ra,dec,mag){

        //deBug("draws", [dc,  ra,dec,mag]);

            var res = raDecToAltAz_deg(ra * byteDeg,proc(dec),lastLoc[0],lastLoc[1],gmst_deg);
            var az = res[0];
            var alt = res[1];
            
            
            //deBug("alt", [az, alt]);
            if (alt<-2) {return null;}
            /*var x = Math.cos(Math.toRadians(az+addAz)) * (90.0 - alt); 
            var y = Math.sin (Math.toRadians(az+addAz)) * (90.0 - alt);

            y = (y + addy) * screenHeight / sizey ;
            x = xc - x * screenWidth /sizex; 
            */

            /*

            //az =xc + (az-xc) *alt /screenHeight; //poor man's spherical projection
            var xy = XY(az, alt);


            mag = (40 - proc(mag))/10; //ranges from about 52 to 0
            if (zoom_level>0) {mag *= 1.5;}
            if ($.Options_Dict[ALLBOLDER] ) {mag *= 2;}
            //mag = mag*mag/700;
            if (mag<1) {mag =1;}
            //mag += 3;
            dc.setColor(starColor,Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(xy[0],xy[1],mag);
            //deBug("PPPPQ3", [az, alt, mag, ra, dec, ra  * byteDeg, proc(dec)]);
            return xy;
    }

    */

    public function drawStar(dc, az,alt,mag){

        //deBug("draws", [dc,  ra,dec,mag]);


            
            
            //deBug("alt", [az, alt]);
            if (alt<-2) {return null;}
            /*var x = Math.cos(Math.toRadians(az+addAz)) * (90.0 - alt); 
            var y = Math.sin (Math.toRadians(az+addAz)) * (90.0 - alt);

            y = (y + addy) * screenHeight / sizey ;
            x = xc - x * screenWidth /sizex; 
            */

            //az =xc + (az-xc) *alt /screenHeight; //poor man's spherical projection
            //deBug("drawst", [az, alt]);
            var xy = XY(az*byteDeg, proc(alt));
            //deBug("drawst", [az, alt, az*byteDeg, proc(alt), xy]);

            /* if (xy[0]<-screenWidth * .3 || xy[0]>screenWidth * 1.3 ||
            xy[1]<-screenHeight * .3 || xy[1]>screenHeight * 1.3 
            ) { return null; } */
        




            mag = (40 - proc(mag))/10; //ranges from about 52 to 0
            if (zoom_level>0) {mag *= 1.5;}
            if ($.Options_Dict[ALLBOLDER] ) {mag *= 2;}
            //mag = mag*mag/700;
            if (mag<1) {mag =1;}
            //mag += 3;
            dc.setColor(starColor,Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(xy[0],xy[1],mag);
            //deBug("PPPPQ3", [az, alt, mag, ra, dec, ra  * byteDeg, proc(dec)]);
            return xy;
    }

    public function plotPlanet(dc, ra,dec, name, jughead){
            //var sizex = jughead[0];
            //var sizey = jughead[1];
            //var addAz = jughead[2];
            //var addy = jughead[3];
            var gmst_deg = jughead[4];
            var res = raDecToAltAz_deg(ra,dec,lastLoc[0],lastLoc[1],gmst_deg);
            var az = res[0];
            var alt = res[1];
            
            //deBug("alt", [az, alt]);
            if (alt<-2) {return;}
            /*
            var x = Math.cos(Math.toRadians(az+addAz)) * (90.0 - alt); 
            var y = Math.sin (Math.toRadians(az+addAz)) * (90.0 - alt);

            y = y * screenHeight / sizey + addy;
            x =xc - x * screenWidth /sizex;
            */

            var xy = XY(az, alt);

            //az =xc + (az-xc) *alt /screenHeight; //poor man's spherical projection


            //mag = (40 - proc(mag))/10; //ranges from about 52 to 0
            //mag = mag*mag/700;
            //if (mag<1) {mag =1;}
            //mag += 3;
            //dc.fillCircle(x,y,mag);
            drawPlanet(dc, name, [xy[0],xy[1],0,0], 2, 0, :orrery, null, null);
            //deBug("PPPPQ3", [key, az, alt, mag, ra, dec, ra  * byteDeg, proc(dec)]);
            dc.setColor(starColor,Graphics.COLOR_TRANSPARENT);
            if ($.Options_Dict[CONSTNAMES]) {
                dc.drawText(xy[0] + xc/8.0 , xy[1] + yc/8.0,starFont,name.substring(0,2),Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
    }

/*
    public function drawConstLineS(dc, cnst, jughead) {

        for  (var i = 0; i<cnst.size(); i++) {
            drawConstLine(dc, cnst[i][0], cnst[i][1], jughead);
        }
    }
    

    public function drawConstLine(dc, s1,s2,jughead){
            //var sizex = jughead[0];
            //var sizey = jughead[1];
            //var addAz = jughead[2];
            //var addy = jughead[3];
            var gmst_deg = jughead[4];
            var res = raDecToAltAz_deg(s1[0] * byteDeg,proc(s1[1]),lastLoc[0],lastLoc[1],gmst_deg);
            var az = res[0];
            var alt = res[1];
            /*
            var x = Math.cos(Math.toRadians(az + addAz)) * (90.0 - alt); 
            var y = Math.sin (Math.toRadians(az + addAz)) * (90.0 - alt);
            
            if (alt<-2) {return;}
        
            y = y * screenHeight / sizey + addy;
            x =xc - x * screenWidth /sizex;
            //az =xc + (az-xc) *alt /screenHeight; //poor man's spherical projection
            */
            /*
            var xy = XY(az, alt);
            
            res = raDecToAltAz_deg(s2[0] * byteDeg,proc(s2[1]),lastLoc[0],lastLoc[1],gmst_deg);
            var az2 = res[0];
            var alt2 = res[1];
            //if (alt2 > 127) {alt2 = alt2 - 256;}
            if (alt2<-2) {return;}

            //if (normalize180(alt2-alt) > 90 || normalize180(az2-az) > 90) {return;}
            /*
            var x2 = Math.cos(Math.toRadians(az2 + addAz)) * (90.0 - alt2); 
            var y2 = Math.sin (Math.toRadians(az2 + addAz)) * (90.0 - alt2);

            if ((x-x2).abs()> screenWidth || (y-y2).abs()>screenHeight) {return;}

            y2 = y2 * screenHeight / sizey + addy;
            x2 =xc - x2 * screenWidth /sizex;

            //az2 =xc + (az2-xc) *alt2 /screenHeight; //poor man's spherical projection
            */

            /*
            if (alt<-5 &&alt2<-5) {return;}

            var xy2 = XY(az2, alt2);

            var dot = 0;
            var thick = 1;

            if ($.Options_Dict[ALLBOLDER]){
                thick = 2;
                dot = 1;
            }
            
            //dc.drawLine(x,y,x2,y2);
            if (zoom_level > 0) { //const lines a little thicker & darker
                
                drawDashedLine (dc,xy[0], xy[1], xy2[0], xy2[1], dot + 1,3, thick + 1, null);

            } else {

                drawDashedLine (dc,xy[0], xy[1], xy2[0], xy2[1], dot,3, thick, null);

            }
            //dc.fillCircle(az,alt,s1[0]*1.5);
            //dc.fillCircle(az2,alt2,s2[0]*1.5);
            //dc.fillCircle(ra,dec,mag);
    }

    */

    public function drawConstLine_new(dc, xy,xy2){
         
            //deBug("dcNEW", [xy,xy2]);
            var dot = 0;
            var thick = 1;

            if ($.Options_Dict[ALLBOLDER]){
                thick = 2;
                dot = 1;
            }
            
            //dc.drawLine(x,y,x2,y2);
            if (zoom_level > 0) { //const lines a little thicker & darker
                
                drawDashedLine (dc,xy[0], xy[1], xy2[0], xy2[1], dot + 1,3, thick + 1, null);

            } else {

                drawDashedLine (dc,xy[0], xy[1], xy2[0], xy2[1], dot,3, thick, null);

            }
            //dc.fillCircle(az,alt,s1[0]*1.5);
            //dc.fillCircle(az2,alt2,s2[0]*1.5);
            //dc.fillCircle(ra,dec,mag);
    }
    /*

    public function drawConstLine_num (key1, key2, sizex, sizey, addAz, addy){

        //drawConstLine()

*/

    public function putText (dc,text,font, justify, jughead){
        if (Math.rand()%3!=0 && zoom_level == 0 ) {return;}
            var ra = jughead[0]  * byteDeg;
            var dec = proc(jughead[1]);
            //var sizex = jughead[2];
            //var sizey = jughead[3];
            //var addAz = jughead[4];
            //var addy = jughead[5];
            var gmst_deg = jughead[6];
            var offsetX = jughead[7];
            var offsetY = jughead[8];

            var res = raDecToAltAz_deg(ra,dec,lastLoc[0],lastLoc[1],gmst_deg); //rad & dec processing done above....
            var az = res[0];
            var alt = res[1];
            if (alt<1) {return;}
            /*

            var x = Math.cos(Math.toRadians(az + addAz)) * (90.0 - alt); 
            var y = Math.sin (Math.toRadians(az +addAz)) * (90.0 - alt);

            
            y = y * screenHeight / sizey + addy;
            x = xc -  x * screenWidth /sizex;
            //az =xc + (az-xc) *alt /screenHeight; //poor man's spherical projection
            */
            var xy = XY(az, alt);
            xy[1] += offsetY;
            xy[0] += offsetX;

        dc.drawText(xy[0], xy[1], font,text,justify);

    }

    (:hasByteArray)
    function proc (x) {
        if (x > 127) {x = x - 256.toNumber(); }
        return  x.toNumber();
    }

    (:noByteArray)
    function proc (x) {
        return  x.toNumber();
    }

    function placeDirections(dc, jughead){
        var dirs = ["N",
                    "NE",
                    "E",
                    "SE",
                    "S", 
                    "SW",
                     "W",
                     "NW",
                     "ZE"
        ];

        var sizex = jughead[0];
        var sizey = jughead[1];
        var addAz = jughead[2];
        var addy = jughead[3];
        //var gmst_deg = jughead[4];                    

        var offset = 5;
        var bottom = 0;
        var addtxt = "";
        var fakeZoom = zoom_level;
        if (zoom_level>4) {fakeZoom = 8-zoom_level;}

        if (fakeZoom > 0 && fakeZoom < 4) {
            offset = 5;
            //bottom = (fakeZoom - 1) *; //make it like the opposite side, once we're over the top...
            //bottom = (zoom_level -1) * 65f/3.0 - 35f;
            bottom = (fakeZoom - 1) * 65f/3.0 - 5;
            
        } else if (zoom_level == 4) {
            offset = 5;
            //bottom = (5 - 1) * 18;
            bottom =  90 - 60/2.0; // center on zenith
        }

        var sFontHeight = dc.getFontHeight(1);
        var dirFont = starFont;
        if (zoom_level > 0) {
          //var sFontHeight = dc.getFontHeight(1);
          dirFont = 1; //smallest
          addtxt = " (Z" + zoom_level + ")";
          dc.drawText(xc - 2*sFontHeight, 0.5*sFontHeight,dirFont,addtxt,Graphics.TEXT_JUSTIFY_CENTER);

        }
        var inc = 45;

        if (zoom_level > 0 && zoom_level!=5) {
            inc = 22.5;
            dirs = ["N",
                    "NNE",   
                    "NE",
                    "ENE",
                    "E",
                    "ESE",
                    "SE",
                    "SSE",
                    "S",
                    "SSW", 
                    "SW",
                    "WSW",
                     "W",
                     "WNW",
                     "NW",
                     "NNW",
                     "ZE"
        ];

        }

        //same color as horizon...
        //dc.setColor(0xe1a75c, Graphics.COLOR_TRANSPARENT);
        //#922fcc
        dc.setColor(0x922fcc, Graphics.COLOR_TRANSPARENT);


        for (var i = 0; i <= 360; i += inc) {
            var dir = dirs[Math.round(i/inc).toNumber()];

            if (zoom_level == 4 && mod(i,90).abs() >0.001) {continue;}
            var x = Math.cos(Math.toRadians(i + addAz)) * (90.0 - offset - bottom); 
            var y = Math.sin (Math.toRadians(i +addAz)) * (90.0 - offset - bottom);

            var zeAddy = 0;
            var zeAddx = 0;
            if (i==360) { //zenith
                x = 0;
                y = 0;
                zeAddy = -sFontHeight/2.0 - 2; //slight offset of ZE to keep text offscreen until we're zoomed
                zeAddx = sFontHeight/2.0;
                //zeAdd = 0;
            }

            
            y = (y +addy)* screenHeight / sizey;
            x = xc -  x * screenWidth /sizex;
            //az =xc + (az-xc) *alt /screenHeight; //poor man's spherical projection
            

            dc.drawText(x + zeAddx, y + zeAddy, dirFont,dir,Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            //putText(dc,dir,1,  Graphics.TEXT_JUSTIFY_CENTER, [pp[p_save][1], pp[p_save][2], sizex, sizey,addAz,addy, gmst_deg, 4, 4]);
            if (i == 360) {
                //dc.setColor(0xe1a75c, Graphics.COLOR_TRANSPARENT);
                // #922fcc // #39d8f7
                dc.setColor(0x39d8f7, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x,y,yc/25); //draw a small circle at zenith
                dc.setColor(0x922fcc, Graphics.COLOR_TRANSPARENT);
            }
        }
    }

    var col, moonh_age_deg,moon_info3;

    var tally = 10000000;
    var tally2 = 10000000;
    var save_keys=[];
    var tally_finished = false;
    var tally2_finished = false;
    var tally3_finished = false;
    var last_started = false;
    var save_moveAz = 0;
    var planets;
    //var gmst_deg = 0;
    var sizex =  90f;
    var sizey = 90f;
    var addy = 0f;
    var addAz = 0f;
    var starColor = Graphics.COLOR_BLACK;
    //var constColor = Graphics.COLOR_LT_GRAY;
    var constColor = 0x65a1c0;
    var starBackgroundColor = Graphics.COLOR_WHITE;
    var starFont = 1;
    var skipConst = false;

    //var cc;
    public function starField(dc) {
         //deBug("RDSWC2: ", null);
         //var zoom_whh, whh;

         
        //var myStats = System.getSystemStats();
        //System.println("Memory1: " + myStats.totalMemory + " " + myStats.usedMemory + " " + myStats.freeMemory);
        //deBug("pp", [$.pp]);

        if (!started&&!select_pressed&&!nextPrev_pressed&&!back_pressed) {
            last_started = false;
            return;
        }

        if ($.pp_hipp == null) {
            deBug("No pp_hipp, return",null);
            return;}

        starColor = Graphics.COLOR_WHITE;
        starBackgroundColor = Graphics.COLOR_BLACK;
        constColor = 0x65a1c0;

        if ($.Options_Dict[REVERSECOLORS] ){
            starColor = Graphics.COLOR_BLACK;
            starBackgroundColor = Graphics.COLOR_WHITE;
            constColor = 0x053130;
        }

        //set up starting or re-starting for the first time
        if ((!last_started && !select_pressed && !nextPrev_pressed && !back_pressed) || $.menu_pressed || onshow)      {
            //deBug("1",null);
            $.started = true;
            $.menu_pressed = false;
            starFont = $.Options_Dict[ALLBOLDER] ? Graphics.FONT_MEDIUM : Graphics.FONT_SMALL;
            tally_finished = false;
            tally2_finished = false;
            tally3_finished = false;
            onshow = false;
            tally = 0;
            tally2 = 0;
            ppNextStar(true, null);
            
            sizex =  92f;
            sizey = 92f;
                    
            addy = 0f;
            zoom_level = 0;
            //deBug("restarting", null);
        }
        last_started = true;
        
        

        if ($.select_pressed || $.back_pressed) {
            //deBug("2",null);

            if ($.select_pressed) {zoom_level += 1; }
            else { zoom_level -= 1; }
            zoom_level = zoom_level%5;

            $.started = true;
            $.nextPrev_pressed = false;
            $.select_pressed = false;
            $.back_pressed = false;
            tally_finished = false;
            tally2_finished = false;
            tally3_finished = false;
            tally = 0;
            tally2 = 0;
            ppNextStar(true, null);

            var fontAdd = 0;
            if ($.Options_Dict[ALLBOLDER]){ fontAdd =1;}

            if (zoom_level == 0) {
                
                    starFont = Graphics.FONT_SMALL + fontAdd;
                    sizex =  92f;
                    sizey = 92f;
                    addy = 0f;
                    
            } else {
                
                    sizex =60f;
                    sizey = 60f;
                    addy = (zoom_level -1) * 65f/3.0 - 35f;
                    starFont = Graphics.FONT_MEDIUM + fontAdd;
                    
   
            }


        }

        /*
        
        for (var i = 0; i < pp.size(); i++) {
            var key = kys[i];
            deBug(key, pp[key]);
        }
        return;
        */

        //note that we must SUBTRACT the TZ & DST factors from our current local time to get the correct JD - the julianDate routine in functions.mc does this
        //var jd_ut = julianDate (now_info.year, now_info.month, now_info.day,now_info.hour, now_info.min, $.now.timeZoneOffset/3600f, $.now.dst);

        //gmst_deg = Math.toDegrees(greenwichMeanSiderealTime(jd_ut));
        
        dc.setColor(starColor,starBackgroundColor);
        
        
        //moveAz 0 == east, 90 = south, 180 = west, 270 = north
        addAz = 0 + moveAz;
        //kys = pp.keys();
        //var kys = ppKeys();
        if (menu_pressed || nextPrev_pressed) {
            //deBug("3",null);
            menu_pressed = false;
            nextPrev_pressed = false;
            started = true;
            last_started = true;
            tally2 = 0;
            ppNextStar(true, null);
            tally = 0;
            
            tally2_finished = false;
            tally_finished = false;
            tally3_finished = false;
            //save_moveAz = moveAz;
        }


        

        if (!tally2_finished && tally_finished && tally3_finished) {
            //deBug("Tally2", null);

            //var star = ppNextStar();
            if (tally2 == 0) {
                ppNextStar(true, null); //reset the queue
                drawHorizon(dc);
                skipConst = ($.Options_Dict[CONSTLINES] || !$.Options_Dict[CONSTNAMES]); 
            }

            
            //deBug("kys", [kys.size(),tally, tally2, kys]);
            /*for (var i=0;i<20;i++) {
            var first2 = tally2;
            var last2 = tally2 + 20;
            if (last2 >= kys.size()) {
                last2 = kys.size();
                tally2_finished = true;
            } */
            //deBug("starsc1", [kys.size(),tally2, first2, last2]);
            dc.setColor(starColor,starBackgroundColor);

            //tally2 += 20;
            //deBug("SF", [sizex,sizey,addAz,addy, jd_ut, gmst_deg, lastLoc]);
            //for (var i = first2; i < last2; i++) {
            for (var i=0;i<30;i++) {
                tally2++;
                //var key = kys[i];
                var star = ppNextStar(null, skipConst);            
                if (star == null) { 
                    tally2_finished = true;
                    break;
                }
                //var pt= star[0];
                //var pt = pp[key[0]][key[1]];
                var az = star[0];
                var alt = star[1];
                var mag = star[2];

                //if (ra<0 || ra > sizex || dec + addy < 0 || dec +addy > sizey) {
                    //deBug("drop", key);
                    //continue;}
                
                //deBug("PPPPQ2:", [ra,dec,mag]);
                drawStar(dc, az,alt,mag); 
                //deBug("ppppq3", [res, star]);
                //if (res[1] < -5) {pp[star[1]].remove(star[2]);}  //remove  stuff below the horizon for memory considerations & we won't ever need/use it      


            } 
        }

        if (!tally3_finished) {
            //deBug("Tally3", null);

            dc.setColor(starColor,starBackgroundColor);

            dc.clear();
            
            

            //if ( tally == 0) {
                //tally2 = 0;
                //ppNextStar(true);
                //tally2_finished = false;
                //save_keys = insertionSort(save_keys );
                //deBug("stars", save_keys);
                //save_keys = [];
                
                placeDirections(dc, [sizex,sizey,addAz,addy]);
                save_moveAz = moveAz;
                
            //}

            

            var whh = toArray(WatchUi.loadResource($.Rez.Strings.planets_Options2) as String,  "|", 0);

            planets = planetCoord($.now_info, $.now.timeZoneOffset, $.now.dst,0, :ecliptic_latlon, whh);

            moon_info3 = eclipticPos_moon_best ($.now_info, $.now.timeZoneOffset, $.now.dst, 0);

            planets.put("Moon",[moon_info3[0], moon_info3[1]]); 
            moon_age_deg = normalize ((planets["Moon"][0]) - (planets["Sun"][0])); //0-360 with 0 being new moon, 90 1st q, 180 full, 270 last q

            moon_info3 = null;
            


            var kys = planets.keys();
            for (var i = 0; i < kys.size(); i++) {
                var key = kys[i];
                //deBug(key, planets[key]);
                plotPlanet(dc, planets[key][0], planets[key][1], key, [sizex,sizey,addAz,addy,gmst_deg] );

            }
            tally3_finished = true;
            return;
        }

        if (!$.Options_Dict[CONSTLINES] && !$.Options_Dict[CONSTNAMES]) {tally_finished = true;}

        if (!tally_finished && tally3_finished) {
            //deBug("Tally", null);
            //var cckys = $.cc.keys();

            /*
            if (tally>cc_name.size()) {
                tally = 0;
                //save_keys = insertionSort(save_keys );
                
                tally_finished = false;
                //save_keys = [];
                //dc.clear();
                //started = false;
            }
            */



            var first = tally;
            var last = tally + 15;
            if (last >= cc_name.size()) {
                last = cc_name.size();
                tally_finished = true;
            }

            //deBug("starsc", [cckys.size(),tally, first, last]);
            tally += 5;

            //dc.setColor(constColor,Graphics.COLOR_TRANSPARENT);
            

            //get & plot all stars for each const, then the lines, then the name
            for (var i = first; i < last; i++) {
                dc.setColor(starColor,Graphics.COLOR_TRANSPARENT);
                var key = $.cc_name[i];
                var c = $.cc_stars[i];
                var k_save = null;
                //var lines = [];
                var c_stars = {};

                for (var j=0; j<c.size();j++) {
                    var p = c[j];
                    if (c_stars.hasKey(p)) {continue;}
                    if (p != null) {
                        k_save = p;
                        var res = drawStar(dc, pp_az[p], pp_alt[p], pp_mag[p]);
                        pp_inConst[p]=true;
                        /*if (res == null) {
                            removeStar(p);

                        }*/
                        //else {
                        if (res!=null) {c_stars.put(p, res); }
                        //}

                    }
                }

                if (k_save != null && $.Options_Dict[CONSTNAMES]) {
                    dc.setColor(constColor,Graphics.COLOR_TRANSPARENT);
                    putText(dc,key, starFont,  Graphics.TEXT_JUSTIFY_CENTER, 
                    [pp_alt[k_save], pp_az[k_save],                    
                    sizex, sizey,addAz,addy, gmst_deg, 4, 4]);
                
                }

                
                if ($.Options_Dict[CONSTLINES]) {
                    dc.setColor(constColor,Graphics.COLOR_TRANSPARENT);
                    //now also draw the LINES with the same info                
                    for (var j= 0; j<c.size()/2; j++) {
                        var p1 = c[2*j];
                        var p2 = c[2*j+1];
                        //var k1 = ppReturnKey(p1);
                        //var k2 = ppReturnKey(p2);
                        if (p1 != null && p2 != null && c_stars[p1] != null && c_stars[p2] != null) {
                            //save_keys.add(p1);
                            //save_keys.add(p2);
                            k_save = p2;
                            //deBug("dcln", [c_stars[p1], c_stars[p2], p1, p2, c_stars]);
                            
                            drawConstLine_new (dc, c_stars[p1],c_stars[p2]);
                            

                        } 
                    }
                }

                
                
                


            }
        }
/*
        if (addLabels) {
            addLabels = false;
            //deBug("adding labels..",null);

            var cckys = $.cc.keys();



            var first = 0;
            var last = cckys.size();
            

            for (var i = first; i < last; i++) {
                if (Math.rand()%2 != 0) {continue;} //add labels to 1/2 of the consts.
                var key = cckys[i];
                var c = $.cc[key];
                var p_save = null;
                for (var j= 0; j<c.size()/2; j++) {
                    var p1 = c[2*j];
                    var p2 = c[2*j+1];
                    
                    if (pp.hasKey(p1) && pp.hasKey(p2)) {
                        //save_keys.add(p1);
                        //save_keys.add(p2);
                        p_save = p2;
                        break;


                    } 
                }
                if (p_save != null) {
                    putText(dc,key,1,  Graphics.TEXT_JUSTIFY_CENTER, [pp[p_save][1], pp[p_save][2], sizex, sizey,addAz,addy, gmst_deg, 4, 4]);
                
                }


            }
            //deBug("adding labels, done..",null);
        }
        */
        

        if (tally2_finished && tally_finished) {
            started = false;
        }

        
        return;
    }

/*
        //dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
        //dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        //getMessage();

        
        //setPosition(Position.getInfo());
        //xc = dc.getWidth() / 2;
        //yc = dc.getHeight() / 2;
   
        r = (xc < yc) ? xc : yc;
        r = .9 * r;

        //deBug("RDSWC3: ", allPlanets);

        font = Graphics.FONT_TINY;
        textHeight = dc.getFontHeight(font);
    




        //*********** SET SCALE/ZOOM LEVEL****************
        var max =0.00001;        
        
        for (var i = 0; i<zoom_whh.size(); i++) {
            key = zoom_whh[i];
            if (whh.indexOf(key)<0) {continue;} //in case dwarf planet/asteroids eliminated by ***planetsOption***
            //System.println("KEY whh: " + key);
            if (pp[key] == null) {continue;}
            var rd = pp[key][0]*pp[key][0]+pp[key][1]*pp[key][1]
               + pp[key][2]*pp[key][2];
            if (rd> max) {max = rd;}
            //System.println("MM: " + key + " " + pp[key][0] + " " + pp[key][1] + " " + rd);
            //if ((pp[key][0]).abs() > maxX) { maxX = (pp[key][0]).abs();}
            //if ((pp[key][1]).abs() > maxY) { maxY = (pp[key][1]).abs();}
        }

     
            //var oldscale = scale;
                //System.println("RDSWC - new scale & targetDc: "  + $.speedWasChanged + " " + $.newModeOrZoom );
                orrZoomOption_values =  toArray(WatchUi.loadResource($.Rez.Strings.orrzoom_values) as String,  "|", 1);
            
                scale = (min_c*0.85*eclipticSizeFactor)/Math.sqrt(max) * $.orrZoomOption_values[$.Options_Dict[orrZoomOption_enum]] ;  
                asteroidsRendered = false;
                orrZoomOption_values = null;

            //must clear screen if scale has changed, otherwise clear it per resetDots setting
            

                if (null != _offscreenBuffer) {
                    targetDc = _offscreenBuffer.getDc();                      
                    targetDc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
                    targetDc.clear();        
                    targetDc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                    targetDc = null;
                    //System.println ("Using offscreenBUFFER");

                } else {
                    targetDc = dc;
                    //System.println ("NOTTTTT Using offscreenBUFFER");
                }
            
            $.newModeOrZoom = false;
            $.speedWasChanged = false;
        


        
        if (ga_rad.abs()>.001 || the_rad.abs() > 0.001) {

            //var oblecl=  obliquityEcliptic_rad ($.now_info.year, $.now_info.month, $.now_info.day, $.now_info.hour + time_add_hrs, 0, 0, 0);

            var oblecl = Math.toRadians(calc_obliq_deg ($.now_info, $.now));
            
            mcob = Math.cos(oblecl);
            msob = Math.sin(oblecl);
            mcgr = Math.cos(ga_rad);
            msgr = Math.sin(ga_rad);
            mctr = Math.cos(the_rad);
            mstr = Math.sin(the_rad);

            //var min_z = 10000000.0f;
            //var max_z = -10000000.0f;
            //var sorter = new [1001];

            for (var i = 0; i<kys.size(); i++) {
                key = kys[i];

                var aster = false;
                if (key.equals("AsteroidA") || key.equals("AsteroidB")) { aster = true;}
                //System.println("ga th: " + ga_rad + " " + the_rad) ;
                //System.println("XYZ PERS: " + key + pp[key]);

                //First we have t ocorrect for the obliquity of the ecliptic
                //which makes the plan of the solar system at a "tilt" to
                //the equatorial coordinates.

                if (aster) {  //asteroid belt, our points represent two points, which we DON'T want to correct for ecliptic (bec. it is already on that plane) and we DON'T want to rotate around Z axis (bec. we want points on the X & Y axis in the final result, for ease of ellipse drawing).
                    y0 = pp[key][1];
                    z0 = pp[key][2];
                    x1 = pp[key][0];
                    y1 = y0;

                }
                else {
                    z0 = pp[key][2] * mcob - pp[key][1] * msob;
                    y0 = pp[key][1] * mcob + pp[key][2] * msob;
                    
                    x1 = pp[key][0] * mcgr - y0 *msgr;
                    y1 = y0 *mcgr + pp[key][0] * msgr;
                    
                }
                //x1 = x;

                y2 = y1 * mctr - z0* mstr;
                var z2 = y1 *mstr + pp[key][2] * mctr;
                //y2 = y1;
                //var pers_fact = (5*mx + (z2+ mx)/2)/6.0/mx;
                pp[key][0] = (x1).toFloat();// *pers_fact;
                pp[key][1] = (y2).toFloat();// * pers_fact; // * pers_fact;
                pp[key][2] = (z2).toFloat();  
                //var z_sort = (Math.floor(z2 * 50).toNumber()) + 500;
                //if (z_sort>1000) {z_sort=1000;}
                //if (z_sort<0) {z_sort=0;}
                
                //if (sorter[z_sort] == null) {sorter[z_sort] = [key];}
                //else {sorter[z_sort].add(key);}
                //if (z2<min_z) {min_z = z2;}
                //if (z2> max_z) {max_z = z2;}
                
                //System.println("XYZ' PERS: " + x2 + " " + y1 + " " );
            }
            kys = null; 
            //System.println("whhbefore: " + whh);
            //deBug("RDSWC11A: ", allPlanets);
            //deBug("RDSWC11Awhh: ", whh);

            //We need to sort by Z values but if the_rad is close to 0 deg or 180 deg we can skip it
            var trmpi = mod(the_rad, Math.PI);
            if (trmpi > Math.PI/4.0 && trmpi < 3* Math.PI/4.0) {
                //zoom_whh = insertionSort(zoom_whh, pp, 2);
                zoom_whh = quickSort(zoom_whh, pp, 2); //was slower than insertion sort.  But on a second try, faster.  Both are probably about the same, sometimes one is better, sometimes the other.
                
                /*zoom_whh = [];
                for (var j = 0; j < sorter.size(); j++) {
                    if (sorter[j]!= null) {
                        zoom_whh.addAll(sorter[j]);
                    }
                }*/

            /*    
            }
            


            if (_offscreenBuffer == null) {
                //for SOME REASON just setting targetDc = dc DOESN"T WORK !!!!??!?!?!?!??!
                //drawOrbits3(dc, pp, scale, xc, yc, big_small, zoom_whh, Graphics.COLOR_WHITE); 
            } else {      
                targetDc = _offscreenBuffer.getDc();      
                //drawOrbits3(targetDc, pp, scale, xc, yc, big_small, zoom_whh, Graphics.COLOR_WHITE);

                //DRAW THE ASTEROID BELT
                if (!asteroidsRendered) {
                                        
                    //targetDc.setPenWidth(1);
                    //targetDc.drawEllipse (xc,yc, pp["AsteroidA"][0].abs() * scale, pp["AsteroidB"][1].abs() * scale );        
                    drawFuzzyEllipse (targetDc,screenWidth, screenHeight, xc,yc, pp["AsteroidA"][0].abs() * scale, pp["AsteroidB"][1].abs() * scale); // ,:high 
                    asteroidsRendered = true;
                } 


                    dc.drawBitmap(0, 0, _offscreenBuffer);
                
 

                targetDc = null;
                
            }
        

        init_findSpotRect();
        LORR_horizon_line_drawn = false;
        //System.println("kys whh " + kys + " \n" + whh);
        for (var i = 0; i<zoom_whh.size(); i++) {
        //for (var i = 0; i<kys.size(); i++) {

            //key1 = kys[i];
            key = zoom_whh[i];
            //System.println ("kys: " + key + " " + key1);
            //if ( ["Ceres", "Uranus", "Neptune", "Pluto", "Eris", "Chiron"].indexOf(key)> -1) {continue;}
            if (key == null || pp[key] == null) {continue;} //not much else to do...
            //if (key1 == null || pp[key1] == null) {continue;} //not much else to do...



            x = scale * pp[key][0] + xc;
            
            y = scale * pp[key][1] + yc;

            var z = scale * pp[key][2];




   
            
            
            

        }





    }
    }
    /*
  

    /*
    //Not sure if this is really necessary for display of  ecliptic planets.  But it does very slightly alter proportions, and makes the 4 ecliptic points fit in as they should.
    private function flattenEclipticPP(obliq_deg){
        var obleq_rad = obliq_deg * Math.PI / 180;
        var mcob = Math.cos(obleq_rad);
        var msob = Math.sin(obleq_rad);
        var kys = pp.keys();
        
        for (var i = 0; i<kys.size(); i++) {
            key = kys[i];
            //deBug("flattenEclipticPP: ", [ key + " " + pp[key]]);
            
            z0 = pp[key][2] * mcob - pp[key][1] * msob;
            y0 = pp[key][1] * mcob + pp[key][2] * msob;

                         
            pp[key][1] = y0;// * pers_fact; // * pers_fact;
            pp[key][2] = z0;  
        }

    }
    */

    

}

