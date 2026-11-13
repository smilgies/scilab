// get_det - get detector parameters

function det_info=get_det(det_info)

    det_head="det_info";

    det_label=["det_make";"scan_type";"det_type"];
    det_label=[det_label;"pixel size";"npix";"nlines"];
    det_label=[det_label;"header";"format";"extension";];
    det_label=[det_label;"binning"];
    det_label=[det_label;"rotate (no/cw/ccw/180)";"flip (no/tb/lr)"];
    det_label=[det_label;"Imin";"Imax"];
    det_label=[det_label;"log scale";"isoview";"use units"];

    // update plot flags
    if det_info(1)<>"custom" then
        log_flag=get_gui_menu("log_flag");
        det_info(15)=string(log_flag);
        iso_flag=get_gui_menu("iso_flag");
        det_info(16)=string(iso_flag);
        unit_flag=get_gui_menu("unit_flag");
        det_info(17)=string(unit_flag);
    end

    // edit box for parameters
    buffer=x_mdialog(det_head,det_label,det_info);

    if buffer<>[] then
        if buffer(1)=="custom" then
            // enter custom parameters
            det_info=buffer;
        else
            // flips (tb/lr) and rotations (cw/ccw/180) are user defined
            det_info(11)=buffer(11);
            det_info(12)=buffer(12);
        end
    end

endfunction
