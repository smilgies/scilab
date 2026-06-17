//
// edit_spots - 3A
//
// show and edit values of calculated spots
// plot edited list of spots
//
// dependencies:
// - called from "edit" pushbutton
// - calls plot_spots

function edit_spots(det_info,plot_info,plot_pars)
    
    // direct beam scattering
    spots_file=TMPDIR+"\spots.dat";
    
    //if det_info(2)=="area" then
    //   spot_header="hn kn ln  x  z  nu del Q  qz qq  qq0 kfx kfz";
    //else
    //   spot_header="hn kn ln nu del Q  qz qq  qq0 kfx kfz";
    //end
    
    // check whether spots file exists
    [f,err]=fileinfo(spots_file);
    
    // read spots and display them in GUI editor
    if err==0 then
        spots=fscanfMat(spots_file);
        new_spots=x_matrix(spots_file,spots);
        renew_flag=new_spots<>[];
        // only edit, if new_spots is not empty (as on exit with "x")
        // on using "okay", spots will be saved and plotted
        if renew_flag then
            fprintfMat(spots_file,new_spots);
        end
    end
    
    // get angles to check for double vision
    alf_i =get_gui_val("alf_i");
    alf_cF=get_gui_val("alf_cF");
    alf_cS=get_gui_val("alf_cS");

    if alf_i>alf_cF & alf_i<alf_cS then
        // reflected beam scattering / double vision
        spots_file=TMPDIR+"\rspots.dat";
        [f,err]=fileinfo(spots_file);
        if err==0 then
            rspots=fscanfMat(spots_file);
            new_spots=x_matrix(spots_file,rspots);
            // only edit when new_spots not empty
            if new_spots<>[] then
                fprintfMat(spots_file,new_spots);
            end
        end 
    end
    
    // replot spots, if list was edited
    // use if only selected spots from list are of interest
    if renew_flag then
        plot_spots(det_info,plot_info,plot_pars);
    end
    
endfunction
