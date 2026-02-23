//////////////////////////////////////////////////////////////////////////////
// plots

function plot_spots(det_info,plot_info,plot_pars)        

    // debug flag
    debug_flag=%F;

    if debug_flag then
        messagebox("in plot-spots");
    end

    // scan_type and units for axes
    scan_type=det_info(2);
    unit_flag=evstr(det_info(17));

    // clean up old plots    
    tag=["beam";"horizon";"yonedaF";"yonedaS";"spots";"rspots"];
    ntag=max(size(tag));
    for itag=1:ntag
        h_plot=findobj("user_data",tag(itag));
        if h_plot<>[] then
            delete(h_plot);
        end
    end

    ////////// clean up hkl labels, if existing  //////
    h_label=findobj("tag","labels");
    if  h_label <> [] then
        delete(h_label.parent.children);
    end
 
    //
    // read spots files
    //

    // direct beam scattering
    spots_file=TMPDIR+"\spots.dat";
    [f,err]=fileinfo(spots_file);
    if err==0 then
        spots=fscanfMat(spots_file);
    end

    // read double vision, if exists
    last_par=max(size(plot_pars));
    refl_flag=plot_pars(last_par);
    if debug_flag then
        messagebox("refl_flag: "+string(refl_flag));
    end
    if refl_flag==1 then
        // reflected beam scattering / double vision
        if debug_flag then
            messagebox("rspots - got here");
        end
        spots_file=TMPDIR+"\rspots.dat";
        [f,err]=fileinfo(spots_file);
        if err==0 then
            rspots=fscanfMat(spots_file);
        end 
    end

    //   
    // plots
    //

    // direct beam defaults
    // dmark_style=5         // diamond
    // dmark_size=10         // (points)
    // dmark_foreground=-1   // rim
    // dmark_background=-2   // fill

    dmark_param=plot_info(1:4);

    // reflected beam defaults
    // rmark_style=6;         // up triangle

    rmark_param=plot_info(5:8);

    if debug_flag then
        messagebox(string(unit_flag));
    end

    my_axes=findobj("user_data","intensity");
    sca(my_axes);

    if scan_type=="area" then 

        if unit_flag==0 then
            x0=plot_pars(1);
            xmin=plot_pars(2);
            xmax=plot_pars(3);

            z0=plot_pars(4);   // direct beam
            zR=plot_pars(5);   // reflected beam
            zH=plot_pars(6);   // horizon
            zYF=plot_pars(7);  // film Yoneda
            zYS=plot_pars(8);  // substrate Yoneda

            refl_flag=plot_pars(9);

            if debug_flag then
                messagebox(string([z0 zR zH zYF zYS]));
            end

            // direct and reflected beam
            // >>> get proper plot symbols from plot_info!!!
            x=[x0,x0];
            z=[z0,zR];
            if plot_info(13)<>"none" then
                mark_param=plot_info(13:16);
                mark_mode="beam";
                plot_mark(x,z,mark_param,mark_mode);
            end

            // horizon
            x=[xmin,xmax];
            z=[zH,zH];
            if plot_info(17)<>"none" then
                line_param=plot_info(17:19);
                line_name="horizon";
                plot_line(x,z,line_param,line_name);
            end

            // Yoneda bands
            x=[xmin,xmax];
            z=[zYF,zYF];
            if plot_info(20)<>"none" then
                line_param=plot_info(20:22);
                line_name="yonedaF";
                plot_line(x,z,line_param,line_name);
            end

            x=[xmin,xmax];
            z=[zYS,zYS];
            line_param=plot_info(23:25);
            if plot_info(23)<>"none" then
                line_name="yonedaS";
                plot_line(x,z,line_param,line_name);
            end

            //    
            // plot spots
            //

            xp=spots(:,4);
            zp=spots(:,5);
            plot_mark(xp,zp,dmark_param,"spots")

            // plot "double vision", if applies
            if refl_flag==1 then
                xr=rspots(:,4);
                zr=rspots(:,5);
                plot_mark(xr,zr,rmark_param,"rspots");
            end

        elseif unit_flag==1 then
            // - use kf values

            // NOTE: macht alles nicht viel Sinn in q ohne zurueckzurechnen ...
            // ... mehr fuer schnelle Bilder
            // hier ein Kompromiss: plotte kf im Laborsystem
            // -> fast dasselbe wie q, aber gut fuer schnelle Bilder

            qxmin=plot_pars(1);
            qxmax=plot_pars(2);

            kfH=plot_pars(3);
            kfR=plot_pars(4);
            kfYF=plot_pars(5);
            kfYS=plot_pars(6);

            refl_flag=plot_pars(7);

            // beams
            qx=[0,0];
            qz=[0,kfR];
            if plot_info(13)<>"none" then
                mark_param=plot_info(13:16);
                mark_mode="beam";
                plot_mark(qx,qz,mark_param,mark_mode);
            end

            // horizon
            qx=[qxmin,qxmax];
            qz=[kfH,kfH];
            if plot_info(17)<>"none" then
                line_param=plot_info(17:19);
                line_name="horizon";
                plot_line(qx,qz,line_param,line_name);
            end

            // Film Yoneda peak
            qx=[qxmin,qxmax];
            qz=[kfYF,kfYF];
            if plot_info(20)<>"none" then
                line_param=plot_info(20:22);
                line_name="yonedaF";
                plot_line(qx,qz,line_param,line_name);
            end

            // Substrate Yoneda peak
            qx=[qxmin,qxmax];
            qz=[kfYS,kfYS];
            if plot_info(23)<>"none" then
                line_param=plot_info(23:25);
                line_name="yonedaS";
                plot_line(qx,qz,line_param,line_name);
            end


            // transform to scattered wavevectors
            kdx=spots(:,12);
            kdz=spots(:,13);
            plot_mark(kdx,kdz,dmark_param,"spots");

            // plot "double vision", if applies
            if refl_flag==1 then
                krx=rspots(:,12);
                krz=rspots(:,13);
                plot_mark(krx,krz,rmark_param,"rspots");
            end

        else
            error("calc_spots >>> unknown unit_flag");
        end

        //////////////////////////////////
    elseif scan_type=="GIRSM" then

        // plot parameters

        nu0=plot_pars(1);
        nustep=plot_pars(2);

        alf_cF=plot_pars(3);
        alf_i=plot_pars(4); 

        refl_flag=plot_pars(5);

        // GID film Yoneda
        mpix=evstr(det_info(5));
        nuYF=(nu0+[0:mpix]*nustep);
        delYF=alf_cF+alf_i*cos(nuYF*%pi/180);
        delYF=delYF*180/%pi;

        plot(nuYF,delYF,'-r');    
        p7=gce();
        p7.user_data="yonedaF";

        // GID: plot nu,del      
        nup=spots(:,4);
        delp=spots(:,5);
        plot_mark(nup,delp,dmark_param,"spots");

        // plot "double vision", if applies
        if refl_flag==1 then
            nur=rspots(:,4);
            delr=rspots(:,5);
            plot_mark(nur,delr,rmark_param,"rspots");
        end

    else
        error("unknown scantype: "+scan_type);  
    end

endfunction


function plot_mark(x,z,mark_param,spot_mode)
    // plot spots
    drawlater
    plot(x,z,"x");     // mode "x", to get mark only set up
    p=gce();
    p.user_data=spot_mode;
    // more powerful plot control via polyline properties
    p.children.mark_style=decode_symbol(mark_param(1));
    p.children.mark_size_unit="point";
    p.children.mark_size=evstr(mark_param(2));
    p.children.mark_foreground=decode_color(mark_param(3));
    p.children.mark_background=decode_color(mark_param(4));
    drawnow;
endfunction

function plot_line(x,z,line_param,line_mode)
    // plot lines
    drawlater;
    plot(x,z,"-");
    p=gce();
    p.user_data=line_mode;
    p.children.line_style=decode_line(line_param(1));
    p.children.thickness=evstr(line_param(2));
    p.children.foreground=decode_color(line_param(3));
    drawnow;
endfunction
