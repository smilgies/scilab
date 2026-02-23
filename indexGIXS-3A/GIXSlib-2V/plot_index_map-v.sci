//
// plot index map - O
//

// dependencies
// - includes fcn "select_spot" from local file
// - calls fcn "xspotlabel" from GIXSlib
// - interactive features do not work in 6.0.n: simplified

function plot_info=plot_index_map(det_info,plot_info,plot_pars)

    // get calculated spots
    filnam=TMPDIR+"\spots.dat";
    [f,err]=fileinfo(filnam);
    if err==0 then
        spots=fscanfMat(filnam);

        irefl=max(size(plot_pars));       // last entry in list
        refl_flag=plot_pars(irefl)==1;    // %T if entry is 1, %F if -1

        [x,z,hkl]=select_spot(spots,det_info);
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
        xmin=round(min(x)*0.7*10)/10;
        xmax=round(max(x)*1.1*10)/10;
        zmin=round(min(z)*0.7*10)/10;
        zmax=round(max(z)*1.1*10)/10;

        // offset for label
        xoff=abs(xmax-xmin)/150;
        plot_info(12)=string(xoff);   // keep track of label offset

        // get back to main window
        my_win=gcf();
        my_axes=gca();

        // for selected points plot indices
        PLOT_SPOTS=%t;
        if PLOT_SPOTS then
            // delete previous points
            h_p1=findobj("user_data","spots");
            if h_p1<>[] then
                delete(h_p1);
            end
            h_p2=findobj("user_data","rspots");
            if h_p2<>[] then
                delete(h_p2);
            end

            // plot and index subset in main plot

            plot_spots(det_info,plot_info,plot_pars);
            h_p1=gce();
            h_p1.user_data="spots";        
            h_label=xspotlabel(x+xoff,z,hkl,"main");

            if refl_flag then
                // plot_spots(det_info,plot_info,plot_pars);
                h_p2=gce();
                h_p2.user_data="rspots";
                h_rlabel=xspotlabel(xr+xoff,zr,hklr,"main");
            end
        else
            messagebox(["no spots calculated" ">>> use  GO"],"indexGIXS warning");
        end
    end
endfunction


// select spot function
function [x,z,hkl]=select_spot(spots,det_info)
    // go through spots to pick one representative

    // unpack det_info
    scan_type=det_info(2);
    unit_flag=evstr(det_info(17));

    // start values
    eps=0.001;
    nn=1;

    if  scan_type=="area" then
        if unit_flag==0 then       // raw image
            xpos=4;
            zpos=5;
        elseif unit_flag==1 then    // use units
            xpos=12;
            zpos=13;
        else
            error("plot_index_map - unknown unit_flag: "+string(unit_flag));
        end
    elseif scan_type=="GIRSM" then
        xpos=4
        zpos=5
    else
        error("scan_type");
    end

    // search unique indices: if next spot has the same x,z, skip it
    x(1)=spots(1,xpos);
    z(1)=spots(1,zpos);
    hkl(1)=string(spots(1,1))+string(spots(1,2))+string(spots(1,3));

    for i=2:size(spots,1)        
        new=%T;
        for n=1:nn
            if abs(spots(i,xpos)-x(n))+abs(spots(i,zpos)-z(n))<eps then
                new=%F;
            end
        end
        if new then
            nn=nn+1;
            x(nn)=spots(i,xpos);
            z(nn)=spots(i,zpos);
            hkl(nn)=string(spots(i,1))+string(spots(i,2))+string(spots(i,3));
        end
    end
endfunction
