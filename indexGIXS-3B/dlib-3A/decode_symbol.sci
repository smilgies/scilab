///////////////////////////////////////
// decode plot mark style

function mark_style=decode_symbol(code)
    // as defined by "polyline_properties"
    select code
    case "circ"
        mark_style=9;
    case "squ"
        mark_style=11;
    case "up"
        mark_style=6;
    case "down"
        mark_style=7;
    case "dia"
        mark_style=5;
    case "+"
        mark_style=1;
    case "x"
        mark_style=2;
    case "ast"
        mark_style=10;
    else
        mark_style=1;
        messagebox("unknown symbol","warning");
    end
endfunction