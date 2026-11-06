// dlib > algebra > vector product 3D

function c=vectorprod(a,b)
    // vector product of two 3D vectors  
    if size(a,1)<>3,
        error("first arg is not a vector of dim 3");
    end
    if size(b,1)<>3,
        error("second arg is not a vector of dim 3"); 
    end
    c(1)=a(2)*b(3)-a(3)*b(2);
    c(2)=a(3)*b(1)-a(1)*b(3);
    c(3)=a(1)*b(2)-a(2)*b(1);
endfunction
