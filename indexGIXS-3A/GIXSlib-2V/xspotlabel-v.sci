// labels for plotted points
// to delete labels all at once: get a.user_data=n,
// then delete(a.children.children(1:n))

function h_label=xspotlabel(x,z,s,flag)
    
    drawlater();
    xstring(x,z,s);
    e=gce();
    h_label=e.parent.children;   // get handles of all labels
    h_label.font_size=3;
    h_label.font_foreground=-2;  // white
    // Scilab font_styles: sans serif(6),sans serif italics (7), sans serif bold (8)
    h_label.font_style=8;
    h_label.tag="labels";
    drawnow();
    
endfunction
