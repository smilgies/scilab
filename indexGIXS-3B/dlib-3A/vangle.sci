// dlib > algebra > angle between 3D vectors

function alf=vangle(a,b)
    // angle between 2 3D vectors
    alf=acos(scalarprod(a,b)/(norm(a)*norm(b)));
endfunction
