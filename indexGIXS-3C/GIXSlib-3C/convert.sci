//
// convert pixels to q - K
// - small-angle approximation only -

function det_info=convert(det_info)

    // unit conversion for area detectors only
    if det_info(2)=="area" then

        // handle of axes
        my_axes=findobj("user_data","intensity");
        sca(my_axes);

        // read checkbox "use units", update det_info
        unit_flag=get_gui_menu("unit_flag");
        det_info(17)=string(unit_flag);

        // size of array/axis vector
        h_grayplot=findobj("user_data","grayplot");
        if h_grayplot==[] then
            if det_info(3)=="3" then
                n=evstr(det_info(5));   // Pilatus V
                m=evstr(det_info(6));
            else
                m=evstr(det_info(5));
                n=evstr(det_info(6));
            end
        else
            m=length(h_grayplot.data.x);
            n=length(h_grayplot.data.y);
        end

        debug_flag=%F;
        if debug_flag then
            msg1="dim: "+string(m)+","+string(n);
            msg2="unit flag: "+string(unit_flag);
            messagebox([msg1,msg2]);
        end

        //
        // pixels to q
        //
        if unit_flag==1 then
            lam=   get_gui_val("lambda");
            L_SD=  get_gui_val("LSD_nu0");
            offset=get_gui_val("offset_nustep");
            x00=   get_gui_val("x0_del0");
            z0=    get_gui_val("z0_delstep");

            pix=evstr(det_info(4));

            // angular range
            x0=x00+offset/pix
            nu1=(1-x0)*pix/L_SD;
            nu2=(m-x0)*pix/L_SD;
            numin=min(nu1,nu2);
            numax=max(nu1,nu2);

            del1=(1-z0)*pix/L_SD;
            del2=(n-z0)*pix/L_SD;
            delmin=min(del1,del2);
            delmax=max(del1,del2);

            // check whether in small angle approximation tth<5deg
            deg=180/%pi;
            warn_flag=abs(numin)>5*deg;
            warn_flag=warn_flag | abs(numax)>5*deg;
            warn_flag=warn_flag | abs(delmin)>5*deg;
            warn_flag=warn_flag | abs(delmax)>5*deg;

            if warn_flag then
                q_lim=(4*%pi/lam)*(5*deg/2);
                messagebox(["beyond small angle limit for q > "+string(q_lim)],... 
                "warning");
                // to be decided how to handle this
            end

            // q-range
            qxmin=(4*%pi/lam)*numin/2;
            qxmax=(4*%pi/lam)*numax/2;
            qzmin=(4*%pi/lam)*delmin/2;
            qzmax=(4*%pi/lam)*delmax/2;

            //updats resize parameters
            set_gui_val("plot_xmin",round(qxmin*100)/100);
            set_gui_val("plot_xmax",round(qxmax*100)/100);
            set_gui_val("plot_zmin",round(qzmin*100)/100);
            set_gui_val("plot_zmax",round(qzmax*100)/100);

            drawlater;
            h_grayplot.data.x=linspace(qxmin,qxmax,m)';
            h_grayplot.data.y=linspace(qzmin,qzmax,n)';
            my_axes.data_bounds=[qxmin qzmin;qxmax qzmax];
            my_axes.x_label.font_size=3;
            my_axes.y_label.font_size=3;
            my_axes.x_label.text="qx (1/nm)";
            my_axes.y_label.text="qz (1/nm)";
            my_axes.font_size=2;
            drawnow;
            
        //
        // back to pixels
        //
        elseif unit_flag==0
            
            set_gui_val("plot_xmin",1);
            set_gui_val("plot_xmax",m);
            set_gui_val("plot_zmin",1);
            set_gui_val("plot_zmax",n);

            drawlater;
            h_grayplot.data.x=[1:m]';
            h_grayplot.data.y=[1:n]';
            my_axes.data_bounds=[1 1;m n];
            my_axes.x_label.font_size=3;
            my_axes.y_label.font_size=3;
            my_axes.x_label.text="x (pixel)";
            my_axes.y_label.text="z (pixel)";
            my_axes.font_size=2;
            drawnow;
        else
            error("convert >>> unknown case");
        end
    else
        messagebox("GIRSM data always in deg","warning");
    end
endfunction
