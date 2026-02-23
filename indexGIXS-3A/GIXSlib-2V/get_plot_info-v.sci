/////////////////////////////////////////////////
// get a plot symbol and update plot
//
// dependencies
// - called via Spot pushbutton
// - uses decode_* functions from dlib

function plot_info=get_plot_info(plot_info);
    // to be renamed get_plot_info

    // input menu - humanly readible
    name  = "specify plot - <color>=blk,red,grn,blu,cya,mag,yel,wht";

    header(1) =  "spots";
    value(1)  =  ">>>";
    header(2) =  "symbol: circ,squ,up,down,dia,+,x";
    value(2)  =  plot_info(1);
    header(3) =  "size (points)";
    value(3)  =  plot_info(2);
    header(4) =  "rim color: <color>,num";
    value(4)  =  plot_info(3);
    header(5) =  "fill color: none,<color>,num";
    value(5)  =  plot_info(4);

    header(6) =  "rspots";
    value(6)  =  ">>>";
    header(7) =  "symbol: circ,squ,up,down,dia,+,x";
    value(7)  =  plot_info(5);
    header(8) =  "size (points)";
    value(8)  =  plot_info(6);
    header(9) =  "rim color: none,<color>,num";
    value(9)  =  plot_info(7);
    header(10)=  "fill color: none,<color>,num";
    value(10) =  plot_info(8);

    // text parameters
    header(11)= "text";
    value(11) = ">>>";
    header(12)= "style: normal,italics,bold";
    value(12) = plot_info(9);
    header(13)= "size (1-5)";
    value(13) = plot_info(10);
    header(14)= "color: <color>";
    value(14) = plot_info(11);
    header(15)= "offset (plot units)";
    value(15) = plot_info(12);
    old_offset= evstr(plot_info(12));

    // line parameters
    header(16)= "lines";
    value(16) = ">>>";
    header(17)= "direct&refl beams - symbol/none";
    value(17) = plot_info(13);
    header(18)= "direct&refl beam - size";
    value(18) = plot_info(14);
    header(19)= "direct&refl beam - rim color";
    value(19) = plot_info(15);
    header(20)="direct&refl beam - fill color";
    value(20) = plot_info(16);

    header(21)= "horizon - line style: none,solid,dash,dot";
    value(21) = plot_info(17);
    header(22)="horizon - thickness (1-5)";
    value(22) = plot_info(18);
    header(23)="horizon - line color";
    value(23) = plot_info(19);

    header(24)="film Yoneda - line style: none,solid,dash,dot";
    value(24) = plot_info(20);
    header(25)="film Yoneda - thickness (1-5)";
    value(25) = plot_info(21);
    header(26)="film Yoneda - line color:";
    value(26) = plot_info(22);

    header(27)="sub Yoneda - line style: none,solid,dash,dot";
    value(27) = plot_info(23);
    header(28)="sub Yoneda - thickness (1-5)";
    value(28) = plot_info(24);
    header(29)="sub Yoneda - line color";
    value(29) = plot_info(25);

    header(30)="plot labels";
    value(30)=">>>";
    header(31)="axes numbers - size (1-5)";
    value(31)=plot_info(26);
    header(32)="axes labels  - size (1-5)";
    value(32)=plot_info(27);
    header(33)="colorbar labels - size (1-5)";
    value(33)=plot_info(28);

    buffer=x_mdialog(name,header,value);

    if buffer~=[] then
        // spots
        plot_info(1)=buffer(2);
        plot_info(2)=buffer(3);
        plot_info(3)=buffer(4);
        plot_info(4)=buffer(5);
        //rspot
        plot_info(5)=buffer(7);
        plot_info(6)=buffer(8);
        plot_info(7)=buffer(9);
        plot_info(8)=buffer(10);
        //text
        plot_info(9)=buffer(12);
        plot_info(10)=buffer(13);
        plot_info(11)=buffer(14);
        plot_info(12)=buffer(15);
        //lines
        // - dir&refl
        plot_info(13)=buffer(17);
        plot_info(14)=buffer(18);
        plot_info(15)=buffer(19);
        plot_info(16)=buffer(20);
        // - horizon
        plot_info(17)=buffer(21);
        plot_info(18)=buffer(22);
        plot_info(19)=buffer(23);
        // - Yoneda F
        plot_info(20)=buffer(24);
        plot_info(21)=buffer(25);
        plot_info(22)=buffer(26);
        // - Yoneda S
        plot_info(23)=buffer(27);
        plot_info(24)=buffer(28);
        plot_info(25)=buffer(29);
        // - axes text
        plot_info(26)=buffer(31);
        plot_info(27)=buffer(32);
        plot_info(28)=buffer(33);

        // update spot symbols
        h_spots=findobj("user_data","spots");
        if h_spots~=[] then
            mark_style=decode_symbol(plot_info(1));
            mark_size=evstr(plot_info(2));
            mark_foreground=decode_color(plot_info(3));
            mark_background=decode_color(plot_info(4));
            h_spots.children.mark_style=mark_style;
            h_spots.children.mark_size_unit="point";
            h_spots.children.mark_size=mark_size;
            h_spots.children.mark_foreground=mark_foreground;
            h_spots.children.mark_background=mark_background; 
        end

        // update rspots, if exist
        h_rspots=findobj("user_data","rspots");
        if h_rspots~=[] then
            mark_style=decode_symbol(plot_info(5));
            mark_size=evstr(plot_info(6));
            mark_foreground=decode_color(plot_info(7));
            mark_background=decode_color(plot_info(8));
            h_rspots.children.mark_style=mark_style;
            h_rspots.children.mark_size_unit="point";
            h_rspots.children.mark_size=mark_size;
            h_rspots.children.mark_foreground=mark_foreground;
            h_rspots.children.mark_background=mark_background; 
        end

        // update text
        new_offset=evstr(plot_info(12));
        for i=1:2
            kk=1;
            h_label=findobj("user_data","lab"+string(kk));
            while h_label<>[]
                h_label.font_style=decode_text(plot_info(9));
                h_label.font_size=evstr(plot_info(10));
                h_label.font_foreground=decode_color(plot_info(11));
                new_xpos=h_label.data(1)-old_offset+new_offset;
                h_label.data(1)=new_xpos;
                kk=kk+1;
                h_label=findobj("user_data","lab"+string(kk));
            end
        end

        // update beam positions and lines
        
        h_beam=findobj("user_data","beam");
        
        if h_beam<>[] then
            if plot_info(13)=="none" then
                delete(h_beam)
            else
                mark_style=decode_symbol(plot_info(13));
                mark_size=evstr(plot_info(14));
                mark_foreground=decode_color(plot_info(15));
                mark_background=decode_color(plot_info(16));
                h_beam.children.mark_style=mark_style;
                h_beam.children.mark_size_unit="point";
                h_beam.children.mark_size=mark_size;
                h_beam.children.mark_foreground=mark_foreground;
                h_beam.children.mark_background=mark_background; 
            end
        end

        h_hor=findobj("user_data","horizon");
        if h_hor<>[] then
            if plot_info(17)=="none"
                delete(h_hor);
            else
                line_style=decode_line(plot_info(17));
                line_width=evstr(plot_info(18));
                line_color=decode_color(plot_info(19));
                h_hor.children.line_style=line_style;
                h_hor.children.thickness=line_width;
                h_hor.children.foreground=line_color; 
            end
        end

        h_yF=findobj("user_data","yonedaF");
        if h_yF<>[] then
            if plot_info(20)=="none" then
                delete(h_yF);
            else
                line_style=decode_line(plot_info(20));
                line_width=evstr(plot_info(21));
                line_color=decode_color(plot_info(22));
                h_yF.children.line_style=line_style;
                h_yF.children.thickness=line_width;
                h_yF.children.foreground=line_color; 
            end
        end

        h_yS=findobj("user_data","yonedaS");
        if h_yS<>[] then
            if plot_info(23)=="none" then
                delete(h_yS);
            else
                line_style=decode_line(plot_info(23));
                line_width=evstr(plot_info(24));
                line_color=decode_color(plot_info(25));
                h_yS.children.line_style=line_style;
                h_yS.children.thickness=line_width;
                h_yS.children.foreground=line_color; 
            end
        end

        // update plot label sizes
        my_axes=findobj("user_data","intensity");
        my_axes.font_size=evstr(plot_info(26));
        my_axes.x_label.font_size=evstr(plot_info(27));
        my_axes.y_label.font_size=evstr(plot_info(27));
        // my_axes.x_label.text="qxy (1/nm)";  // for future use
        // my_axes.y_label.text="qz (1/nm)";
        my_bar=findobj("user_data","colorbar");
        my_bar.font_size=evstr(plot_info(28));

    end
endfunction

//////////////////////////////////////////////////////////////////////
// auxiliary functions to decode point and line specifiers >>> dlib-2D
