// dlib > plot > lin lin log (3D)

function linlinlog   // 3D plots only
    a=gca();
    // note: error check for positive x,y is built in
    set(a,"log_flags","nnl");
endfunction