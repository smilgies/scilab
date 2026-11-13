function [mat,txt]=read_Mat(filnam)

    // patch for finnicky fscanfMat
    fd=mopen(filnam);
    aux=mgetl(fd);
    mclose(fd);

    // split up into txt and mat    
    i=0;
    loop=%t;
    while loop do
        i=i+1;
        test=tokens(aux(i));
        if isnum(test(1)) then
            imax=i-1;
            loop=%f;
        end 
    end
    
    txt=aux(1:imax);
    mat=evstr(aux(imax+1:$));

endfunction
