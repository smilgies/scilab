// dlib > plot > x log, y lin

function loglin
    a=gca();
    // note: error check for positive x is built in
    set(a,"log_flags","lnn");
endfunction
