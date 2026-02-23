// get menu item (listbox)
// note: will eventually replace get_gui_menu
// description

// description:
// listbox value: option = number of chosen item
// listbox string: list of all items
// item is the string associated option

function item=get_gui_item(tag)
    handle=findobj("tag",tag);
    option=handle.value;
    list_items=handle.string
    item=list_items(option)
endfunction
