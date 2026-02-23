//
// initialize plot image - Mx
//

// using autoscale feature of grayplot 
// (see also captureGIXS and processGIXS)

function plot_init(mat,level_num,det_info)
    
    // clean up previous grayplot
    h_grayplot=findobj("user_data","grayplot");
    if h_grayplot<>[] then
        delete(h_grayplot);
    end

    // plot image 
    if mat<>[] then

        // set contour levels
		// (avoid changing levels and flags for adjacent files)
        plot_min=get_gui_val("plot_min");
        plot_max=get_gui_val("plot_max");
        log_flag=get_gui_menu("log_flag");
        iso_flag=get_gui_menu("iso_flag");
        
        // scale plot
        level_fac=(level_num+8)/level_num;  // extended color scale
           
        if log_flag==0 then
            // - linear scale
            aa=double(mat);
            aa=max(aa,plot_min);
            aa=min(aa,plot_max);
            // finetune for grayplot auto scaling
            aa(1,1)=plot_min;  // ensure that min/max are assumed
            // correct for extended color map for plotting symbols
            aa(1,2)=plot_max*level_fac;
        elseif log_flag==1 then
            // - log scale
            // avoid accidental zeroes
            log_plot_min=log10(max(plot_min,1));
            log_plot_max=log10(max(plot_max,1));
            aa=log10(max(mat,1));
            aa(1,1)=log_plot_max;
            aa=max(aa,log_plot_min);
            aa=min(aa,log_plot_max);
            // finetune for grayplot auto scaling
            aa(1,1)=log_plot_min;  // ensure that min/max are assumed
            aa(1,2)=log_plot_max*level_fac;
        else
            messagebox("error in log_flag");
        end

        // axis calibration
        scan_type=det_info(2);
        if scan_type=="GIRSM" then
            nu0=get_gui_val("LSD_nu0");
            nustep=get_gui_val("offset_nustep");
            del0=get_gui_val("x0_del0");
            delstep=get_gui_val("z0_delstep");
        end      

        // create grayplot object and its handle
        drawlater;
        
        // - find axes
        my_axes=findobj("user_data","intensity");
        sca(my_axes);      // assign active graph
        
        // - set axes range
        [mpix,npix]=size(aa);
        if scan_type=="area" then
            x=1:mpix;
            y=1:npix;
            my_axes.data_bounds=[0,0;mpix,npix];
        elseif scan_type=="GIRSM" then
            x=nu0+nustep*[0:mpix-1];
            numax=max(x);
            y=del0+delstep*[0:npix-1];
            delmax=max(y);
            my_axes.data_bounds=[nu0,del0;numax,delmax];
        end

        // - isoscale y/n
        if iso_flag==1 then
            my_axes.isoview="on";
        else
            my_axes.isoview="off";
        end

        // - plot
        grayplot(x,y,aa);

        h_grayplot=gce();
        h_grayplot.clip_state="clipgrf";
        h_grayplot.user_data="grayplot";

        // - update colorbar
        my_colorbar(level_num,plot_min,plot_max,log_flag);

        drawnow;

        // update plot size to max plot area
        if scan_type=="area" then
            set_gui_menu("unit_flag",0);
            set_gui_val("plot_xmin",1);
            set_gui_val("plot_xmax",mpix);
            set_gui_val("plot_zmin",1);
            set_gui_val("plot_zmax",npix);
        elseif scan_type=="GIRSM" then
            set_gui_menu("unit_flag",1);
            set_gui_val("plot_xmin",round(nu0*10)/10);
            set_gui_val("plot_xmax",round(numax*10)/10);
            set_gui_val("plot_zmin",round(del0*10)/10);
            set_gui_val("plot_zmax",round(delmax*10)/10);
        else
            error("unknown scan_type: "+scan_type);
        end

    else
        // no file read in
    end

endfunction
