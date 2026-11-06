// dlib > plot > log log

function loglog
    a=gca();
    // note: error check for positive x,y is built in
    set(a,"log_flags","lln");
endfunction
