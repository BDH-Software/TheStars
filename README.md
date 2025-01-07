The Stars shows you the night sky - planets, sun, moon, constellations, and all stars down the magnitude 4.0.

Find the constellations, the planets - whatever is out tonight, or today.

This app is very simple: It shows you exactly what stars and celestial objects are up right now, where you are.  The app opens looking towards the east, with a view of the stars and constellations from the horizon all the way to the zenith.

Controls are simple as well:

 - Up & Down buttons (or corresponding swipes, depending on your device) move your view leftwards or rightwards around the points of the compass.  Each view is looking in one compass direction or subdirection (E, ENE, NE, NNE, N, etc) and from horizon all the way to the zenith.

- Want to zoom in?  Just press START (or the similar START/STOP/SELECT tap or button on your device). You will instantly zoom in closer.  Press START again and you will gradually move upwards to the Zenith, and then continue on all the way around to the opposite horizon.

- Along the way you can use UP/DOWN to move left or right at the current altitude.

- Long Press of MENU will instantly un-zoom and return you to the horizon.

- Continually pressing START (note indicator Z1, Z2, Z3 - etc) will take you to the opposite horizon and then with one more press of START you un-zoom and return to the starting point.

 - BACK button exits.

 - No options or menu items. It's just the stars and planets exactly where and when you are right now.

PLANETS and the MOON are abbreviated by the first two letters. These are the same abbreviations used in the companion app/widget/watchface THE PLANETS.  Full list here: https://github.com/bhugh/ThePlanets/wiki/The-Planets-for-Garmin-%E2%80%90-General-Information

CONSTELLATIONS are indicated with their standard 3-letter abbreviations. The full list is here: https://en.wikipedia.org/wiki/IAU_designated_constellations

Zoomed out you will see a smattering of constellation names.  When you zoom in via START you will see ALL constellation names in that area.

STAR POSITIONS are adapted from the magnitude 4 version of the Hipparcos Star Catalog, prepared and formatted by Greg Miller, with many emendations to fill out major constellations.

Planetary & Sun positions are based on Miller's implementation of the VSOP87a PICO algorithm, which is generally accurate to about +/-1.2 degrees for +/-4000 years from the present. https://www.celestialprogramming.com/vsop87-multilang/index.html

Moon position & phase are again based on Miller's work: https://celestialprogramming.com/lowprecisionmoonposition.html  Note that this "low precision" algorithm gives a moon position within 1 degree of the "High Precision" algorithm for roughly +/- 5000 years from the present.  Only at time scales longer than the does it begin to fail badly.

**ABOUT THE FIRST RELEASE**

First release the THE STARS for Garmin watches & devices.  This project presented considerable difficulty: Just the star location data ALONE fills more memory than is allotted to a complete App for many Garmin devices. The star-to-constellation data is similar in size.  

So fitting all that PLUS the code needed to render it at reasonable speed on low-powered devices has been a real challenge.

The app runs on most Garmin devices, from the Instinct 2 up through Fenix 8 & FR 965.  A few older devices (Vivoactive HR, Edge 520, D2 Charlie, etc), don't support the bytearray compression used for the data, so they are not included as compatible devices.  The App runs very well on my Instinct 2 and should run on all devices listed.

Enjoy!

*Planet abbreviations:*
 * Sun
 * Me Mercury
 * Ve Venus
 * Ea Earth
 * Mo Moon
 * Ma Mars
 * Ju Jupiter
 * Sa Saturn     
 * Ur Uranus 
 * Ne Neptune     
 * Pl Pluto

*Constellation abbreviations*
The 88 constellations and their standard 3-letter abbreviations, along with pronunciation and other helpful information, is [on the Sky and Telescope web page](https://skyandtelescope.org/astronomy-resources/constellation-names-and-abbreviations/).  The App includes all 88 constellations.


**APP TECHNICAL DETAILS**

Using the [Greg Miller's VSOP Pico algorithm](https://github.com/gmiller123456/vsop87-multilang/blob/master/Languages/JavaScript/vsop87a_pico.js) gives [nearly all planetary positions 4000BC-6000AD within 1.2 degrees of actual position](https://celestialprogramming.com/vsop87-multilang/index.html) (and accuracy is far better 2125 +/-100 years).  Moving to the Nano algorithm was attempted and would improve accuracy by about 3X but takes a large amount of memory and runs far slower on today's smartwatches - perhaps in a future version!

Monkey C for Garmin IQ watches.

**CREDITS & LICENSE:**

_****** Planetary, sun, & moon positions, star catalog filtering & formatting:_  [Greg Miller's version of the VSOP Pico algorithm](https://github.com/gmiller123456/vsop87-multilang/blob/master/Languages/JavaScript/vsop87a_pico.js)  [Miller's presentation of the Hipparcos Star Catalog Data](https://github.com/gmiller123456/hip2000). [Miller's presentation of the Constellation Stick Figures based on Stellarium (GPL)](https://www.celestialprogramming.com/snippets/ConstellationStickFigures/constellationStickFigures.html).

Both the star catalog and constellation stick figures have been extensively edited and amended to work well in the limited conditions of a watch operating system. A large number of stars beyond the 4.0 magnitide limit were added in order to fill out constellation outlines.

 ** LICENSE of Miller's VSOP code: PUBLIC DOMAIN

_SOFTWARE LICENSE_
 * Portions due to Greg Miller's implementation of the VSOP algorithm Public Domain.
 * Portions due to Stellarium: GPL.
 * Hipparcos Star Catalog: Public Domain.
 * Remainder Copyright 2024 Brent Hugh.

