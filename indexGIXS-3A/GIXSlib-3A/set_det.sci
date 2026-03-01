//
// set the detector information det_info - U
//

// retrieve list item from GUI
// ported to dlib as get_gui_item
// function item = get_gui_list_item(tag)
//     h = findobj("tag",tag)
//     item = h.string(h.value)
// endfunction


// detector database
function det_info=set_det()

    // det_type=get_gui_menu("detector_type");
    
    // det_type = get_gui_list_item("detector_type")
    
    // new in dlib-2T
    det_type = get_gui_item("detector_type")

    debug_flag=%f;
    if debug_flag then
        disp("det_type="+det_type);    // debug
    end

    // supported detector types
    select det_type
        
    case "MedOptics"
        // MedOptics TIFF
        det_make="MedOptics";
        scan_type="area";
        header_bytes=8;
        npix=1024;   // pixels per line
        nlines=1024; // lines to read
        trailer_bytes=190;
        pixel_size=0.0469;
        fmt="us";
        ext="*.tif";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=15;
        Imax=15000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        // test lattice / start values - Josh's nanocubes
        set_gui_val("a",17);
        set_gui_val("b",17);
        set_gui_val("c",17);
        set_gui_val("alf",70);
        set_gui_val("bet",70);
        set_gui_val("gam",70);
        // index_rule
        set_gui_menu("index_rule",1);
        // plane
        set_gui_val("H",1);
        set_gui_val("K",1);
        set_gui_val("L",1);
        set_gui_val("s_factor",1);
        // angles
        set_gui_val("alf_i",0.25);
        set_gui_val("alf_cF",0.13);
        set_gui_val("alf_cS",0.18);
        // set-up
        set_gui_val("lambda","0.117");
        set_gui_val("LSD_nu0",946);
        set_gui_val("offset_nustep",0);
        set_gui_val("x0_del0",916.6);
        set_gui_val("z0_delstep",61.9);
        // reset to default
        my_axes=findobj("user_data","intensity");
        my_axes.data_bounds=[0,0;1000,1000];
        
    case "FLI Cam"
        // FLI Cam TIFF (G1)
        det_make="FLI Cam";
        scan_type="area";
        header_bytes=4096;
        npix=1024;
        nlines=1024;
        trailer_bytes=190;
        pixel_size=0.068;
        fmt="us";
        ext="*.tif";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=50;
        Imax=50000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        // test lattice - Michelle's gyroid
        set_gui_val("a",67);
        set_gui_val("b",72);
        set_gui_val("c",72);
        set_gui_val("alf",90);
        set_gui_val("bet",90);
        set_gui_val("gam",90);
        // index_rule
        set_gui_menu("index_rule",12);
        // plane
        set_gui_val("H",2);
        set_gui_val("K",1);
        set_gui_val("L",1);
        set_gui_val("s_factor",0.46);
        // angles
        set_gui_val("alf_i",0.165);
        set_gui_val("alf_cF",0.12);
        set_gui_val("alf_cS",0.18);
        // set-up
        set_gui_val("lambda",0.125);
        set_gui_val("LSD_nu0",2679);
        set_gui_val("offset_nustep",0);
        set_gui_val("x0_del0",514.5);
        set_gui_val("z0_delstep",118);
        
    case "Pilatus V"
        // Pilatus 100k vertical orientation
        det_make="Pilatus 100k V"
        scan_type="area";
        header_bytes=4096;
        npix=487;
        nlines=195;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="ui";
        ext="*.tif*";
        nbin=1;
        rot_mode="cw";
        flip_mode="no";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        // TIPS-pn thin film from RRL
        // thin film structure: Mannsfeld & Bao, Adv Mater 23, 127 (2011)
        // values1=["  0.77","  0.783","  1.678","  103.5","  88.0","  96.4"];
        set_gui_val("a",0.77);
        set_gui_val("b",0.783);
        set_gui_val("c",1.678);
        set_gui_val("alf",103.5);
        set_gui_val("bet",88.0);
        set_gui_val("gam",96.4);
        // index_rule
        set_gui_menu("index_rule",1);
        // plane
        set_gui_val("H",0);
        set_gui_val("K",0);
        set_gui_val("L",1);
        set_gui_val("s_factor",1);
        // angles
        set_gui_val("alf_i",0.15);
        set_gui_val("alf_cF",0.15);
        set_gui_val("alf_cS",0.18);
        // set-up
        set_gui_val("lambda",0.1265);
        set_gui_val("LSD_nu0",190);
        set_gui_val("offset_nustep",42);
        set_gui_val("x0_del0",82);
        set_gui_val("z0_delstep",58);
        // plot axes
        
    case "Pilatus H"
        // Pilatus 100k horizontal orientation
        det_make="Pilatus 100k H";
        scan_type="area";
        header_bytes=4096;
        npix=487;
        nlines=195;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="ui";
        ext="*.tif*";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
        case "Pilatus 200k"
        // Pilatus 200k horizontal gap orientation
        det_make="Pilatus 200k";
        scan_type="area";
        header_bytes=4096;
        npix=487;
        nlines=407;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.tif*";
        nbin=1;
        rot_mode="180";
        flip_mode="no";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
        case "Pilatus 300k"
        // Pilatus 300k horizontal gap orientation
        det_make="Pilatus 300k";
        scan_type="area";
        header_bytes=4096;
        npix=487;
        nlines=619;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.tif*";
        nbin=1;
        rot_mode="180";
        flip_mode="no";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        // lattice - Mannsfeld's TIPS-pn thin film structure
        //set_gui_val("a",0.770);
        //set_gui_val("b",0.783);
        //set_gui_val("c",1.667);
        //set_gui_val("alf",103.5);
        //set_gui_val("bet",88);
        //set_gui_val("gam",99);
        // lattice - Anthony diF-TES-ADT bulk
        set_gui_val("a",0.721);
        set_gui_val("b",0.732);
        set_gui_val("c",1.635);
        set_gui_val("alf",87.72);
        set_gui_val("bet",89.99);
        set_gui_val("gam",71.94);
        // index_rule: P
        set_gui_menu("index_rule",1);
        // plane
        set_gui_val("H",0);
        set_gui_val("K",0);
        set_gui_val("L",1);
        set_gui_val("s_factor",1);
        
    case "G2 raw"
        // G2 raw data
        det_make="HERMES diode array - raw"
        scan_type="GIRSM";
        header_bytes=0;  // could be used for header lines
        npix=300;    // dummy
        nlines=640;  // HERMES array length
        trailer_bytes=0;
        pixel_size=0.179;
        fmt="ascii";
        ext="*.txt";
        nbin=1;
        rot_mode="no";
        flip_mode="no";
        Imin=1;
        Imax=500;
        log_flag=0;
        iso_flag=0;
        unit_flag=1;
        // lattice - Stephanie's TES-ADT
        set_gui_val("a",0.696);
        set_gui_val("b",0.747);
        set_gui_val("c",1.675);
        set_gui_val("alf",96);
        set_gui_val("bet",92);
        set_gui_val("gam",106);
        // index_rule: P
        set_gui_menu("index_rule",1);
        // plane
        set_gui_val("H",0);
        set_gui_val("K",0);
        set_gui_val("L",1);
        set_gui_val("s_factor",1);
        // angles
        set_gui_val("alf_i",0.13);
        set_gui_val("alf_cF",0.13);
        set_gui_val("alf_cS",0.20);
        // set-up
        set_gui_val("lambda",0.144);
        set_gui_val("LSD_nu0",10);
        set_gui_val("offset_nustep",0.05);
        set_gui_val("x0_del0",-0.076);
        set_gui_val("z0_delstep",0.0189);
        
    case "G2 calibrated"
        // G2 calibrated data
        det_make="HERMES diode array - cal"
        scan_type="GIRSM";
        header_bytes=7;  // could be used for header lines
        npix=300;        // dummy
        nlines=640;      // HERMES array length
        trailer_bytes=0;
        pixel_size=0.179;
        fmt="ascii";
        ext="*.txt";
        nbin=1;
        rot_mode="no";
        flip_mode="no";
        Imin=1;
        Imax=500;
        log_flag=0;
        iso_flag=0;
        unit_flag=1;
        // lattice - Mannsfeld's TIPS-pn thin film structure
        //set_gui_val("a",0.770);
        //set_gui_val("b",0.783);
        //set_gui_val("c",1.667);
        //set_gui_val("alf",103.5);
        //set_gui_val("bet",88);
        //set_gui_val("gam",99);
                
        // lattice - Anthony diF-TES-ADT bulk
        set_gui_val("a",0.721);
        set_gui_val("b",0.732);
        set_gui_val("c",1.635);
        set_gui_val("alf",87.72);
        set_gui_val("bet",89.99);
        set_gui_val("gam",71.94);
        // index_rule: P
        set_gui_menu("index_rule",1);
        // plane
        set_gui_val("H",0);
        set_gui_val("K",0);
        set_gui_val("L",1);
        set_gui_val("s_factor",1);
        // angles
        set_gui_val("alf_i",0.13);
        set_gui_val("alf_cF",0.13);
        set_gui_val("alf_cS",0.20);
        // set-up
        set_gui_val("lambda",0.144);
        set_gui_val("LSD_nu0",10);
        set_gui_val("offset_nustep",0.05);
        set_gui_val("x0_del0",-0.076);
        set_gui_val("z0_delstep",0.0189);
        //more precise calibration read from data file
        
    case "custom"
        // custom
        det_make="custom" // set to PIL 300k default 
        scan_type="area";
        header_bytes=4096;   // strip offsets
        npix=487;   // pixels per line
        nlines=619; // lines to read
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.tif";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=30000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        // plot image size for simulation
        myaxes=findobj("user_data","intensity");
        myaxis.data_bounds=[0,0;npix,nlines];
        
    case "Image Plate"
        // Typhoon FLA 7000 IP scanner 
        // software binned 2x2
        det_make="Image Plate";
        scan_type="area";
        pixel_size=0.100;
        npix=2500;
        nlines=2000;
        header_bytes=8;
        fmt="us";
        ext="*.tif";
        nbin=2;
        rot_mode="no";
        flip_mode="tb";
        Imin=100;
        Imax=65000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "Princeton"
        // Princeton camera
        det_make="Princeton";
        scan_type="area";
        pixel_size=0.024;
        npix=2084;
        nlines=2084;
        header_bytes=8;
        fmt="us";
        ext="*.tif";
        nbin=2;
        rot_mode="no";
        flip_mode="no";
        Imin=100;
        Imax=65000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "Eiger 1M"
        // Eiger 1M
        det_make="Eiger 1M TIFF";   // Dectris ALBULA converter/TVX
        scan_type="area";
        header_bytes=4096;
        npix=1030;
        nlines=1065;
        trailer_bytes=0;
        pixel_size=0.075;
        fmt="i";
        ext="*.tif";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "matrix"
        // Matrix: for Pilatus 200k dual exposure mode
        det_make="matrix";
        scan_type="area";
        header_bytes=4096;
        npix=487;
        nlines=407;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.mtx";
        nbin=1;
        rot_mode="no";
        flip_mode="no";
        Imin=50;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
	case "Pilatus 1M tvx"
    // Pilatus 1M for Dectris TVX files
    det_make="Pilatus 1M tvx";
        scan_type="area";
        header_bytes=4096;
        npix=981;
        nlines=1043;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.tif*";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "Pilatus 2M tvx"
        //Pilatus 2M for Dectris TVX files
        det_make="Pilatus 2M tvx";
        scan_type="area";
        header_bytes=4096;
        npix=1475;
        nlines=1679;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.tif*";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "Pilatus 1M cms"
        det_make="Pilatus 1M tif";   // Dectris ALBULA converter
        scan_type="area";
        header_bytes=4096;
        npix=981;
        nlines=1043;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.tif*";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
	case "Pilatus 1M gb"
        // Pilatus 1M using ALS GB converter
        det_make="Pilatus 1M gb";   // ALS GB converter
        scan_type="area";
        header_bytes=0;
        npix=981;
        nlines=1043;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="f";
        ext="*.gb";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "Pilatus 2M cms"
        det_make="Pilatus 2M tif";  // Dectris ALBULA converter
        scan_type="area";
        header_bytes=4096;
        npix=1475;
        nlines=1679;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="i";
        ext="*.tif*";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "Pilatus 2M gb"
        det_make="Pilatus 2M gb";   // ALS GB converter  1475 x 1679 
        scan_type="area";
        header_bytes=0;
        npix=1475;
        nlines=1679;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="f";
        ext="*.gb";
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
    case "Ganesha 300k"
        // Pilatus 300k vertical gap orientation
        // formatting for Xenocs Ganesha raw data (UTA)
        det_make="Ganesha 300k";
        scan_type="area";
        header_bytes=8;
        npix=619;
        nlines=487;
        trailer_bytes=0;
        pixel_size=0.172;
        fmt="us";
        ext="*.tif*";
        nbin=1;
        rot_mode="no";
        flip_mode="no";
        Imin=1;
        Imax=5000;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
        // presets for GIWAXS mode
        set_gui_val("a",1.15);
        set_gui_val("b",0.85);
        set_gui_val("c",2.55);
        set_gui_val("alf",90);
        set_gui_val("bet",90);
        set_gui_val("gam",100);
        // index_rule
        set_gui_menu("index_rule",1);
        // plane
        set_gui_val("H",0);
        set_gui_val("K",0);
        set_gui_val("L",1);
        set_gui_val("s_factor",1);
        // angles
        set_gui_val("alf_i",0.18);
        set_gui_val("alf_cF",0.18);
        set_gui_val("alf_cS",0.18);
        // set-up
        set_gui_val("lambda",0.15406);    // Cu-Ka
        set_gui_val("LSD_nu0",140);
        set_gui_val("offset_nustep",0);
        set_gui_val("x0_del0",270);
        set_gui_val("z0_delstep",57);
    
    case "Xenocs EDF"
        // Eiger 1M for Xenocs Xeuss 3 beamlines (RUC,DTU)
        det_make="Xenocs Eiger 1M";
        scan_type="area";
        pixel_size=0.075;
        fmt="f";
        ext="*.edf";
        header_bytes=4096;
        npix=1030;
        nlines=1065;
        trailer_bytes=0;
        nbin=1;
        rot_mode="no";
        flip_mode="tb";
        Imin=1;
        Imax=500;
        log_flag=1;
        iso_flag=1;
        unit_flag=0;
        
        // presets for GIWAXS mode: BTBT test image
        // 
        set_gui_val("a",0.5907);
        set_gui_val("b",0.7890);
        set_gui_val("c",2.9086);
        set_gui_val("alf",90);
        set_gui_val("bet",91.94)
        set_gui_val("gam",90);
        // index_rule
        set_gui_menu("index_rule",1);
        // plane
        set_gui_val("H",0);
        set_gui_val("K",0);
        set_gui_val("L",1);
        set_gui_val("s_factor",1);
        // experiments parameters defined by read_image.sci
        
    else
        disp(det_type);
        messagebox("set_det >>> det_type X"+det_type+"X not supported");
    end
    
    // update det_info  
    det_info(1)=det_make;
    det_info(2)=scan_type;
    det_info(3)=det_type;
    det_info(4)=string(pixel_size);
    det_info(5)=string(npix);
    det_info(6)=string(nlines);
    det_info(7)=string(header_bytes);
    det_info(8)=fmt;
    det_info(9)=ext;
    det_info(10)=string(nbin);
    det_info(11)=rot_mode;     // value=no/cw/ccw/180
    det_info(12)=flip_mode;    // value=no/tb/lr
    det_info(13)=string(Imin);
    det_info(14)=string(Imax);
    det_info(15)=string(log_flag);
    det_info(16)=string(iso_flag);
    det_info(17)=string(unit_flag);
    
    //
    // graphics presets
    //

    // set plot ranges
    set_gui_val("plot_min",Imin);
    set_gui_val("plot_max",Imax);
    set_gui_val("plot_xmin",1);
    set_gui_val("plot_zmin",1);
    if det_type=="Pilatus V" then
        set_gui_val("plot_xmax",nlines);
        set_gui_val("plot_zmax",npix);
    else
        set_gui_val("plot_xmax",npix);
        set_gui_val("plot_zmax",nlines);
    end
    
    // set graphics modes
    set_gui_menu("log_flag",log_flag);
    set_gui_menu("iso_flag",iso_flag);
    set_gui_menu("unit_flag",unit_flag);

    // flexible set-up menu
    // - set-up labels for D1/G2 set-ups
    if scan_type=="area" then
        set_gui_txt("LSD_nu0_label","  L_SD (mm)");
        set_gui_txt("offset_nustep_label","  offset (mm)");
        set_gui_txt("x0_del0_label","  x0 (pixels)");
        set_gui_txt("z0_delstep_label","  z0 (pixels)");
    elseif scan_type=="GIRSM" then
        set_gui_txt("LSD_nu0_label","  nu0 (deg)");
        set_gui_txt("offset_nustep_label","  nustep (deg)");
        set_gui_txt("x0_del0_label","  del0 (deg)");
        set_gui_txt("z0_delstep_label","  delstep (deg)");
    else
        error("unknown scan_type: "+scan_type);
    end

    // axes labels and range
    // - find axes object
    my_axes=findobj("user_data","intensity");

    // - range of interest
    drawlater;
    if scan_type=="area" then
        if  det_make=="Pilatus 100k V" then
            my_axes.data_bounds=[0,0;nlines,npix];
        else
            my_axes.data_bounds=[0,0;npix,nlines];
        end
        my_axes.x_label.font_size=3;
        my_axes.y_label.font_size=3;
        my_axes.x_label.text="x (pixel)";
        my_axes.y_label.text="z (pixel)";
    elseif scan_type=="GIRSM" then
        // plot angle range
        nu0=get_gui_val("LSD_nu0");
        nustep=get_gui_val("offset_nustep");
        del0=get_gui_val("x0_del0");
        delstep=get_gui_val("z0_delstep")  
        numax=nu0+(npix-1)*nustep;
        delmax=del0+(nlines-1)*delstep;
        my_axes.data_bounds=[nu0,del0;numax,delmax];
        // set axes labels
        my_axes.x_label.font_size=3;
        my_axes.y_label.font_size=3;
        my_axes.x_label.text="nu (deg)";
        my_axes.y_label.text="del (deg)";
    end

    // - font size
    my_axes.font_size=2;

    if iso_flag==1 then
        my_axes.isoview="on";
    else
        my_axes.isoview="off";
    end
    drawnow;

    // detector calibration (essential for G2 raw data)
    if det_make=="G2 raw" then
        set_gui_txt("read_status",">>> input detector calibration");
    else
        set_gui_txt("read_status","[input file]");
    end

endfunction
