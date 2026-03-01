function cleanup_labels()
    
    // clean up hkl labels, if existing
    
    // due to inconsistent handling of xstring in 2026 and 2023
    version=getversion();
    
    if version=="scilab-2026.0.0" | version=="scilab-2026.0.1" then
        // disp("cleanup_labels: "+version);
        h_label=findobj("tag","labels");
        if  h_label <> [] then
            delete(h_label);
        end
        h_rlabel=findobj("tag","rlabels");
        if  h_rlabel <> [] then
            delete(h_rlabel);
        end

    elseif version=="scilab-2023.1.0" then
        // disp("cleanup_labels: "+version);
        h_label=findobj("tag","labels");
        if  h_label <> [] then
            delete(h_label.parent.children);
        end
        h_rlabel=findobj("tag","rlabels");
        if  h_rlabel <> [] then
            delete(h_rlabel.parent.children);
        end
        
    else
        messagebox("unsupported scilab version: use 2026.0.1 or 2023.1.0");
    end
    
endfunction
