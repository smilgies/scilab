function cleanup_plot()

    // delete all previous spots and lines    
    tag=["beam";"horizon";"yonedaF";"yonedaS";"spots";"rspots"];
    ntag=max(size(tag));
    for itag=1:ntag
        h_plot=findobj("user_data",tag(itag));
        if h_plot<>[] then
            delete(h_plot);
        end
    end
    
endfunction
