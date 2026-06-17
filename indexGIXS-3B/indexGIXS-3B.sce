/////////////////////
//  indexGIXS 3.0  //
/////////////////////

//
// Version 3B  -  Jun 2026
//                for scilab-2026.0.1 under Windows 10 and 11 Home edition
//                for scilab-2023.1.0 under Windows 11 Enterprise
//
// Author:   Detlef Smilgies
//

// system settings
// - avoid error messages on recompile
funcprot(0);

// - set look and feel "windows classic" 
setlookandfeel("com.sun.java.swing.plaf.windows.WindowsClassicLookAndFeel");

// - get screen size
screen=get(0,"screensize_px");
screenH=screen(3);
screenV=screen(4);

version=getversion();
yr=evstr(part(version,8:11));


///////////////////////////////////////
// main

//
// define path
//
// local program directory
LOCAL=pwd();

// prepare initial data path
path=LOCAL;
mputl(path,TMPDIR+"\path.par");

// LIBRARIES

// load library of small aux functions
dlib=lib(LOCAL+"\dlib-3A");
// use "generate_dlib.sce" to compile updated library

// load library of GIXS functions
GIXSlib=lib(LOCAL+"\GIXSlib-3B");
// use "generate_GIXSlib" to compile updated library

// load menu files
// note: call menus in order
LOCMENU=LOCAL+"\menus-3B\"

//
// build GUI
//
if screenV>900 then
    // parameters for desktop screen: e.g. 1920 x 1080
    // - GUI parameters
    exec(LOCMENU+"gui_param-dt.sci");
    // - window lay-out
    exec(LOCMENU+"win_design-dt.sci");
    // - load image menu  
    exec(LOCMENU+"load_menu.sci");
    // - plot menu
    exec(LOCMENU+"plot_menu.sci");
    // - calculation menu
    exec(LOCMENU+"calc_menu-dt.sci");

else
    // parameters for laptop screen: e.g. 1366 x 768
    exec(LOCMENU+"gui_param-lt.sci");
    exec(LOCMENU+"win_design-lt.sci");
    exec(LOCMENU+"load_menu.sci");
    exec(LOCMENU+"plot_menu.sci");
    exec(LOCMENU+"calc_menu-lt.sci");
end



