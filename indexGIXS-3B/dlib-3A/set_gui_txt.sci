// GUI text
function set_gui_txt(tag,txt);
    handle=findobj("tag",tag);
    handle.string=txt;
endfunction