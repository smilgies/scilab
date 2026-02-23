// set GUI menu (listbox, checkbox)
function set_gui_menu(tag,option)
    handle=findobj("tag",tag);
    handle.value=option;
endfunction