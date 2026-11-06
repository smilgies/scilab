//////////////////////////
// decode plot text style

function text_style=decode_text(code)
    select code
    case "normal"
        text_style=6;
    case "italics"
        text_style=7;
    case "bold"
        text_style=8;
    end
endfunction