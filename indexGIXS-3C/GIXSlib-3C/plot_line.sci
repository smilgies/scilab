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
