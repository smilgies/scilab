// retrieve GUI text
function txt=get_gui_txt(tag)
    handle=findobj("tag",tag);
    txt=handle.string;
endfunction