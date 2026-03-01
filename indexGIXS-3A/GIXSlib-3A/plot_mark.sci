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
