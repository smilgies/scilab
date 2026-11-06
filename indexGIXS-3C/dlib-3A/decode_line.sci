//////////////////////////////////
// decode_line - plot line styles

function line_style=decode_line(code)
    select code
    case "solid"
        line_style=1;
    case "dash";
        line_style=2;
    case "dot"
        line_style=3;
    else
        messagebox("unknown line style: "+code,"warning")
    end
endfunction