//
// set_lattice()
//

// called by
// - main (index rule dropdown menu)

function set_lattice()
    
    // input lattice
    lattice=get_gui_menu("index_rule");
    
    // set lattice parameters and close-packed orientation
    // for selected cases
    
    select lattice
    case 7  // sc
    // standard SC lattice
    a=get_gui_val("a");
    set_gui_val("b",a);
    set_gui_val("c",a);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",90);

    // close-packed plane: HKL=(001),S=1
    set_gui_val("H",0);
    set_gui_val("K",0);
    set_gui_val("L",1);
    set_gui_val("s_factor",1);
    
    case 8  // bcc
    // standard BCC lattice
    a=get_gui_val("a");
    set_gui_val("b",a);
    set_gui_val("c",a);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",90);

    // close-packed plane: HKL=(110),S=1
    set_gui_val("H",1);
    set_gui_val("K",1);
    set_gui_val("L",0);
    set_gui_val("s_factor",1);
        
    case 9  // fcc
    // standard FCC lattice
    a=get_gui_val("a");
    set_gui_val("b",a);
    set_gui_val("c",a);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",90);
    
    // close-packed plane: HKL=(111),S=1
    set_gui_val("H",1);
    set_gui_val("K",1);
    set_gui_val("L",1);
    set_gui_val("s_factor",1);
    
    case 10  // hcp
    // ideal HCP lattice
    a=get_gui_val("a");
    set_gui_val("b",a);
    c=int(a*sqrt(8/3)*100)/100;
    set_gui_val("c",c);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",120);
    
    // close-packed plane: HKL=(001),S=1
    set_gui_val("H",0);
    set_gui_val("K",0);
    set_gui_val("L",1);
    set_gui_val("s_factor",1);
    
    case 11  // dia
    // standard FCC lattice
    a=get_gui_val("a");
    set_gui_val("b",a);
    set_gui_val("c",a);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",90);
    
    // close-packed plane: HKL=(111),S=1
    set_gui_val("H",1);
    set_gui_val("K",1);
    set_gui_val("L",1);
    set_gui_val("s_factor",1);
    
    case 12  // sgl gyr
    // single gyroid lattice
    a=get_gui_val("a");
    set_gui_val("b",a);
    set_gui_val("c",a);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",90);

    // close-packed plane: HKL=(110)
    set_gui_val("H",1);
    set_gui_val("K",1);
    set_gui_val("L",0);
    set_gui_val("s_factor",1);
    
    case 13  // dbl gyr
    // double gyroid lattice
    a=get_gui_val("a");
    set_gui_val("b",a);
    set_gui_val("c",a);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",90);

    // close-packed plane: HKL=(112),S=1
    set_gui_val("H",1);
    set_gui_val("K",1);
    set_gui_val("L",2);
    set_gui_val("s_factor",1);
    
    case 14  // cyl
    // 2D HEX lattice (cylinders)
    a=get_gui_val("a");
    set_gui_val("b",a);
    set_gui_val("c",0.01);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",120);
    
    // close-packed plane: HKL=(001),S=1
    set_gui_val("H",1);
    set_gui_val("K",0);
    set_gui_val("L",0);
    set_gui_val("s_factor",1);
    
    case 15  // lam
    // lD LAM ()lamellae)
    a=get_gui_val("a");
    set_gui_val("b",0.01);
    set_gui_val("c",0.01);
    set_gui_val("alf",90);
    set_gui_val("bet",90);
    set_gui_val("gam",90);
    
    // close-packed plane: HKL=(100),S=1
    set_gui_val("H",1);
    set_gui_val("K",0);
    set_gui_val("L",0);
    set_gui_val("s_factor",1);
    
    else
        // no presets 
    end

endfunction
