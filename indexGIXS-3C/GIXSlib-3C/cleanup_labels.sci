function cleanup_labels()
    
    // clean up hkl labels, if existing
    
    // due to inconsistent handling of xstring in 2026/7 and 2023
    version=getversion();

    if version=="scilab-2023.1.0" then
        
        h_label=findobj("tag","labels");
        if  h_label <> [] then
            delete(h_label.parent.children);
        end
        h_rlabel=findobj("tag","rlabels");
        if  h_rlabel <> [] then
            delete(h_rlabel.parent.children);
        end
        
    else
        
         h_label=findobj("tag","labels");
        if  h_label <> [] then
            delete(h_label);
        end
        h_rlabel=findobj("tag","rlabels");
        if  h_rlabel <> [] then
            delete(h_rlabel);
        end
        
    end
    
endfunction
