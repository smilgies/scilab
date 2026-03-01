// dlib > gui > set up radio group

function radio_group(h_group,h_on)
    // handles of radio buttons forming a group are handed over as h_group
    // the active button is given in the second argument h_on
    n=max(size(h_group,1),size(h_group,2));
    for i=1:n
        set(h_group(i),"value",0);
    end
    set(h_on,"value",1);
endfunction
