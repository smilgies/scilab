//
// plot_index_map
//

// dependencies
// - called by "index" pushbutton from main menu
// - calls "select_spot"
// - calls "plot_spots"

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

        // calculate ROI
        ///xmin=round(min(x)*0.7*10)/10;
        ///xmax=round(max(x)*1.1*10)/10;
        ///zmin=round(min(z)*0.7*10)/10;
        ///zmax=round(max(z)*1.1*10)/10;

        // offset for label
        // xoff=abs(xmax-xmin)/150;  dnw - to be fixed in 3B

        // retrieve x offset value
        xoff=evstr(plot_info(12));   // keep track of label offset

        // get back to main window/intensity plot
        //my_win=gcf();
        h_win=findobj("tag","main_window");
        my_win=scf(h_win);
        // my_axes=gca();
        h_axes=findobj("tag","intensity");
        my_axes=sca(h_axes);


        // plot and index subset in main plot
        plot_spots(det_info,plot_info,plot_pars);

        // due to inconsistencies for xstring in 2023 and 2026
        version=getversion();

        // plot labels
        if version=="scilab-2026.0.0" | version=="scilab-2026.0.1" then
            // disp("index: "+version);
            drawlater();
            h_label=xstring(x+xoff,z,hkl);
            h_label.tag="labels";

            // label properties
            h_label.children.font_size=3;
            h_label.children.font_foreground=-2;  // white
            // Scilab font_styles: sans serif(6),sans serif italics (7), sans serif bold (8)
            h_label.children.font_style=8;
            drawnow();

            if refl_flag then
                drawlater();
                h_rlabel=xstring(x+xoff,z,hklr);
                h_rlabel.children.font_size=3;
                h_rlabel.children.font_foreground=-2;  // white
                h_rlabel.children.font_style=8;
                h_rlabel.tag="rlabels";
                drawnow();
            end

        elseif version=="scilab-2023.1.0" then
            // disp("index: "+version);
            drawlater();
            xstring(x+xoff,z,hkl);
            e=gce();
            e.tag="labels";
            h_label=e.parent;

            // label properties
            h_label.children.font_size=3;
            h_label.children.font_foreground=-2;  // white
            // Scilab font_styles: sans serif(6),sans serif italics (7), sans serif bold (8)
            h_label.children.font_style=8;
            drawnow();

            if refl_flag then
                drawlater();
                xstring(x+xoff,z,hklr);
                e=gce();
                e.tag="rlabels";
                h_rlabel=e.parent

                // rlabel properties
                h_rlabel.children.font_size=3;
                h_rlabel.children.font_foreground=-2;  // white
                h_rlabel.children.font_style=8;
                h_rlabel.tag="rlabels";
                drawnow();
            end

        else
            messagebox("unsupported scilab version: use 2026.0.1 or 2023.1.0");
        end
        
    else    
        messagebox("no calculated spots found: use calc first")
    end
    
endfunction
