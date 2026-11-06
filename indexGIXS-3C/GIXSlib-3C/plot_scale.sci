//
// plot scale - update scaling of grayplot object - L
//

// using autoscale feature of grayplot

function plot_scale(mat,level_num)

    // set contour levels
    plot_min=get_gui_val("plot_min");
    plot_max=get_gui_val("plot_max");
    log_flag=get_gui_menu("log_flag");        

    level_fac=(level_num+8)/level_num;  // extended color scale   

    // scale plot     
    if log_flag==0 then
        // - linear scale
        aa=double(mat);
        aa=max(aa,plot_min);
        aa=min(aa,plot_max);
        // finetune for auto scaling
        aa(1,1)=plot_min;  // ensure that min/max are assumed
        // correct for extended color map for plotting symbols
        aa(1,2)=plot_max*level_fac;
    elseif log_flag==1 then
        // - log scale
        // avoid accidental zeroes
        log_plot_min=log10(max(plot_min,1));
        log_plot_max=log10(max(plot_max,1));
        aa=log10(max(mat,1));
        aa=max(aa,log_plot_min);
        aa=min(aa,log_plot_max);
        // finetune for auto scaling
        aa(1,1)=log_plot_min;  // ensure that min/max are assumed
        // correct for extended color map for plotting symbols
        aa(1,2)=log_plot_max*level_fac;
    else
        error("error in log_flag");
    end

    // assign active graph
    h_myaxes=findobj("user_data","intensity");
    sca(h_myaxes);      

    h_grayplot=findobj("user_data","grayplot");
    // plot by updating the data.z property of the grayplot object
    h_grayplot.data.z=aa; 

    // clean up buffer
    clear aa;

    // update colorbar
    my_colorbar(level_num,plot_min,plot_max,log_flag)

endfunction
