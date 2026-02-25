/////////////////////
//  indexGIXS 3.0  //
/////////////////////

//
// Version 3A  -  Feb 2026
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

// note: indexGIXS uses 2 types of libraries:
// - proper library: dlib (compiled functions loaded by "lib")
// - function library: GIXSlib (functions invoked by "exec")

// load library of small aux functions
dlib=lib(LOCAL+"\dlib-2T");
// use "generate_dlib.sce" to compile updated library

// local GIXS library
LOCLIB=LOCAL+"\GIXSlib-2V\";

// load GIXS library functions
exec(LOCLIB+"read_image-v.sci");
exec(LOCLIB+"read_Mat-v.sci");
exec(LOCLIB+"plot_init-v.sci");
exec(LOCLIB+"plot_scale-v.sci");
exec(LOCLIB+"plot_ROI-v.sci");
exec(LOCLIB+"reciprocal_lattice-v.sci");
exec(LOCLIB+"real_lattice-v.sci");
exec(LOCLIB+"find_hkl-v.sci");
exec(LOCLIB+"calc_spots-v.sci");
exec(LOCLIB+"plot_spots-v.sci");
exec(LOCLIB+"edit_spots-v.sci");
exec(LOCLIB+"plot_index_map-v.sci");
exec(LOCLIB+"get_plot_info-v.sci");
exec(LOCLIB+"set_det-v.sci");
exec(LOCLIB+"get_det-v.sci");
exec(LOCLIB+"set_sgel-v.sci");
exec(LOCLIB+"set_lattice-v.sci");
exec(LOCLIB+"convert-v.sci");
exec(LOCLIB+"my_colorbar-v.sci");
exec(LOCLIB+"xspotlabel-v.sci");

// load menus
// note: keep menus in order

// local menus library
LOCMENU=LOCAL+"\menus-2V\"

//
// build GUI
//
if screenV>900 then
    // parameters for desktop screen: e.g. 1920 x 1080
    // - GUI parameters
    exec(LOCMENU+"gui_param-nv.sci");
    // - window lay-out
    exec(LOCMENU+"win_design-rv.sci");
    // - load image menu  
    exec(LOCMENU+"load_menu-v.sci");
    // - plot menu
    exec(LOCMENU+"plot_menu-v.sci");
    // - calculation menu
    exec(LOCMENU+"calc_menu-nv.sci");

else
    // parameters for laptop screen: e.g. 1366 x 768
    exec(LOCMENU+"gui_param-pv.sci");
    exec(LOCMENU+"win_design-sv.sci");
    exec(LOCMENU+"load_menu-v.sci");
    exec(LOCMENU+"plot_menu-v.sci");
    exec(LOCMENU+"calc_menu-pv.sci");
end

//   end of main   //


