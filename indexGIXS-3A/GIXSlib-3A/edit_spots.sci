//
// edit_spots - K
//
// show and edit values of calculated spots
//

function edit_spots(det_info)
    // direct beam scattering
    spots_file=TMPDIR+"\spots.dat";
    //if det_info(2)=="area" then
    //   spot_header="hn kn ln  x  z  nu del Q  qz qq  qq0 kfx kfz";
    //else
    //   spot_header="hn kn ln nu del Q  qz qq  qq0 kfx kfz";
    //end
    [f,err]=fileinfo(spots_file);
    if err==0 then
        spots=fscanfMat(spots_file);
        new_spots=x_matrix(spots_file,spots);
        // only edit, if new_spots is not empty (as on exit with "x")
        if new_spots<>[] then
            fprintfMat(spots_file,new_spots);
        end
    end
    
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
endfunction
