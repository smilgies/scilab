//
// plot_index_map
//

// dependencies
// - called by "index" pushbutton from main menu
// - calls "select_spot"
// - calls "plot_spots"
// - calls "dlib/decode_color"
// - calls "dlib/decode_text"

function plot_info=plot_index_map(det_info,plot_info,plot_pars)

    // get calculated spots
    filnam=TMPDIR+"\spots.dat";
    [f,err]=fileinfo(filnam);
    if err==0 then
        spots=fscanfMat(filnam);

        irefl=max(size(plot_pars));       // last entry in list
        refl_flag=plot_pars(irefl)==1;    // %T if entry is 1, %F if -1
        // simpler: refl_flag=plot_pars($)==1;

        // select unique representative of hkl
        [x,z,hkl]=select_spot(spots,det_info);

        // check for reflected beam scattering
        if refl_flag then
            // get calculated rspots
            f2nam=TMPDIR+"\rspots.dat";
            [f,err]=fileinfo(f2nam);
            if err==0 then
                rspots=fscanfMat(f2nam);
            else
                messagebox(["no rspots file"],"indexGIXS warning");
            end
            [xr,zr,hklr]=select_spot(rspots,det_info);
        end

        // unpack plot_info
        // - font_styles: sans serif(6),sans serif italics (7), sans serif bold (8)
        fontstyle=decode_text(plot_info(9));
        // - font size (1-5)   
        fontsize=evstr(plot_info(10));
        // - font color (look-up table in decode_color)
        fontcolor=decode_color(plot_info(11));
        // - retrieve x offset value
        xoff=evstr(plot_info(12));   // keep track of label offset

        // get back to main window/intensity plot
        // - set current figure
        my_win=findobj("tag","main_window");
        scf(my_win);
        // - set current axes
        my_axes=findobj("tag","intensity");
        sca(my_axes);


        // plot and index subset in main plot
        plot_spots(det_info,plot_info,plot_pars);

        // due to inconsistencies for xstring in versions 2023.1.0 and 2026.1.0
        version=getversion();

        // plot labels
        if version=="scilab-2026.1.0" | version=="scilab-2026.0.1" then
            // disp("index: "+version);
            drawlater();
            h_label=xstring(x+xoff,z,hkl);
            h_label.tag="labels";

            // set label properties
            h_label.children.font_size=fontsize;
            h_label.children.font_foreground=fontcolor;
            h_label.children.font_style=fontstyle;
            drawnow();

            if refl_flag then
                drawlater();
                h_rlabel=xstring(x+xoff,z,hklr);
                h_rlabel.children.font_size=fontsize;
                h_rlabel.children.font_foreground=fontcolor;
                h_rlabel.children.font_style=fontstyle;
                h_rlabel.tag="rlabels";
                drawnow();
            end

        elseif version=="scilab-2023.1.0" then
            
            drawlater();
            xstring(x+xoff,z,hkl);
            e=gce();
            e.tag="labels";
            h_label=e.parent;

            // set label properties
            h_label.children.font_size=fontsize; 
            h_label.children.font_foreground=fontcolor;
            h_label.children.font_style=fontstyle;
            drawnow();

            if refl_flag then
                drawlater();
                xstring(x+xoff,z,hklr);
                e=gce();
                e.tag="rlabels";
                h_rlabel=e.parent

                // rlabel properties
                h_rlabel.children.font_size=fontsize;
                h_rlabel.children.font_foreground=fontcolor;
                h_rlabel.children.font_style=fontstyle;
                h_rlabel.tag="rlabels";
                drawnow();
            end

        else
            messagebox("unsupported scilab version: use 2026.1.0 or 2023.1.0");
        end
        
    else    
        messagebox("no calculated spots found: use calc first")
    end
    
endfunction
