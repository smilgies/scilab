// dlib > algebra > scalar product 3D

function c=scalarprod(a,b)
    // scalar product of two 3D vectors
    if size(a,1)<>3,
        error("first arg is not a vector of dim 3");
    end
    if size(b,1)<>3,
        error("second arg is not a vector of dim 3"); 
    end
    c=a(1)*b(1)+a(2)*b(2)+a(3)*b(3);
endfunction
