/////////////////////////////////////
// GUI parameters
//

// dimensions
// window
winw=900;      // width
winh=720;      // hite
// GUI
guiw=250;       // width
guih=750;       // hite
// GUI boxes: left (name) and right (input) 
boxw1=100;  
boxw2=100;
boxh=25;
marginv=5;
offsetv=5;
// default GUI font size
FontSize=12;
// GUI background for input fields (light grey vs. mid grey default)
back=[0.9,0.9,0.9];

//
// main GUI: positions
//
guiposh1=winw-guiw;                   // left column
guiposh2=guiposh1+boxw1;              // right column
//
guiposv=guih-6.5*boxh;                // loop 1
guiposv2=guih-15*boxh-offsetv;        // loop 2
guiposv3=guih-20*boxh-1.5*offsetv;    // loop 3
guiposv4=guih-24*boxh-2*offsetv;      // loop 4

// plot GUI: positions
plotguih=85;
plotguih2=plotguih-25;
plotguih3=plotguih2-25;
hoff=40;
