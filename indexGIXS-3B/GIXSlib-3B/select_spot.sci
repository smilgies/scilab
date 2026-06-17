// select spot function
function [x,z,hkl]=select_spot(spots,det_info)
    // go through equivalent spots to pick one representative

    // unpack det_info
    scan_type=det_info(2);
    unit_flag=evstr(det_info(17));

    // start values
    eps=0.001;
    nn=1;

    if  scan_type=="area" then
        if unit_flag==0 then       // raw image
            xpos=4;
            zpos=5;
        elseif unit_flag==1 then    // use units
            xpos=12;
            zpos=13;
        else
            error("plot_index_map - unknown unit_flag: "+string(unit_flag));
        end
    elseif scan_type=="GIRSM" then
        xpos=4
        zpos=5
    else
        error("scan_type");
    end

    // search unique indices: if next spot has the same x,z, skip it
    x(1)=spots(1,xpos);
    z(1)=spots(1,zpos);
    // ... and generate label
    hkl(1)=string(spots(1,1))+string(spots(1,2))+string(spots(1,3));

    // search loop
    for i=2:size(spots,1)        
        new=%T;
        for n=1:nn
            if abs(spots(i,xpos)-x(n))+abs(spots(i,zpos)-z(n))<eps then
                new=%F;
            end
        end
        if new then
            nn=nn+1;
            x(nn)=spots(i,xpos);
            z(nn)=spots(i,zpos);
            hkl(nn)=string(spots(i,1))+string(spots(i,2))+string(spots(i,3));
        end
    end
    
endfunction
