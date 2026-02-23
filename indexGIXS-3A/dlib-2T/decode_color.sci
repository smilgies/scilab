/////////////////////////////////////////
// fcn decode_color: determine color code

function color_code=decode_color(code)
    // relative to jetcolormap(32)
    // (defaults: wht=-2,blk=-1,transparent=0)
    // (colors 1-32 given by jetcolormap)
    // (8 additional primary colors)
    select code
    case "blk"
        color_code=33;
    case "red"
        color_code=34;
    case "grn"
        color_code=35;
    case "blu"
        color_code=36;
    case "cya"
        color_code=37;
    case "mag"
        color_code=38;
    case "yel"
        color_code=39;
    case "wht"
        color_code=40;
    case "none"
        color_code=0;
    else
        if isnum(code) then
            color_code=evstr(code);
            if color_code>=1 & color_code<=32+8 then
                color_code=round(evstr(code));   // out of colormap
            else
                color_code=-1; // black
                messagebox("unknown color code: "+code,"warning");
            end
        else
            color_code=-1;
            messagebox("unknown color: "+code,"warning");
        end
    end
endfunction