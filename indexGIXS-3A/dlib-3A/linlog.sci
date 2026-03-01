// dlib > plot > x lin, y log

function linlog
    a=gca();
    // note: error check for positive y is already built in
    set(a,"log_flags","nln");
endfunction