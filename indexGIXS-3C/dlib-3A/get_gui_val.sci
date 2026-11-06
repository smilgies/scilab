// retrieve GUI value (editbox)
function val=get_gui_val(tag)
    handle=findobj("tag",tag);
    val=evstr(handle.string);
endfunction