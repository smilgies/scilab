// get menus (checkbox, listbox)
function option=get_gui_menu(tag)
    handle=findobj("tag",tag);
    option=handle.value;
endfunction