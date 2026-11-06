// output GUI value
function set_gui_val(tag,val);
    handle=findobj("tag",tag);
    handle.string="  "+string(val);
endfunction