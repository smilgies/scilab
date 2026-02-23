//
// set_lattice()
//

// called by
// - main (index rule dropdown menu)

function set_lattice()
    
    // input lattice
    lattice=get_gui_menu("index_rule");
    
    // messagebox("index_rule: "+string(lattice));   // debug
    
    // set lattice parameters and close-packed orientation
    // for selected cases
    
    select lattice
    case 7  // sc
        sc();
    case 8  // bcc
        bcc();
    case 9  // fcc
        fcc();
    case 10  // hcp
        hcp();   //hard sphere lattice
    case 11  // dia
        fcc();
    case 12  // sgl gyr
        sgyr();
    case 13  // dbl gyr
        gyr();
    case 14  // cyl
        cyl();
    case 15  // lam
        lam();
    else
        // no presets 
    end

endfunction


//
// preset special lattices

function fcc()
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
endfunction

function hcp()
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
endfunction

function bcc()
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
endfunction

function sgyr()
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
    set_gui_val("L",0);
    set_gui_val("s_factor",1);
endfunction

function gyr()
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
endfunction

function sc()
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
endfunction

function cyl()
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
endfunction

function lam()
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
endfunction
