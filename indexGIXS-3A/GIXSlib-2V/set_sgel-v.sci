//
// set_sgel - set space group elements

// called by calc_menu
// preset: sg_info=[">>>";"1";"1";"1";">>>";"none";"none";"none";">>>";"5";"5";"5";"B";">>>";"real"];

function sg_info=set_sgel(sg_info)

    // previous mode
    prev_mode = sg_info($)

    // use text instead of cryptic numbers
    sg_head="index rules";

    sg_label=["screw axes";"a: 1, 2, 3, 4, 6";"b: 1, 2, 3, 4, 6";"c: 1, 2, 3, 4, 6"];
    sg_label=[sg_label;"glide planes";"none, a/b, a/c, a/n";"none, b/c, b/a, b/n";"none, c/a, a/b, c/n"];
    sg_label=[sg_label;"index range";"Hmax";"Kmax";"Lmax";"Mode (L/R/B)"]
    sg_label=[sg_label;"search space";"real/reciprocal (real/rec)"];

    // edit box for parameters
    buffer=x_mdialog(sg_head,sg_label,sg_info);

    if buffer~=[] then
        // update sgel
        sg_info=buffer;        
    end

    // mark push button, if rule is set
    sg_default=[">>>";"1";"1";"1";">>>";"none";"none";"none"];
    h_rule_set=findobj("tag","rule_set");

    if and(sg_info(1:8)==sg_default) then
        h_rule_set.string="  index rule";
        h_rule_set.foregroundcolor=[0 0 0];  // black text
    else
        h_rule_set.foregroundcolor=[0.7 0 0];  // red text
        h_rule_set.string="  SG elements";
    end

    if sg_info($) ~= prev_mode then

        // switch between real and reciprocal space search
        if sg_info($)=="rec" then

            // retrieve real space lattice
            a=get_gui_val("a");
            b=get_gui_val("b");
            c=get_gui_val("c");
            alf=get_gui_val("alf")*%pi/180;
            bet=get_gui_val("bet")*%pi/180;
            gam=get_gui_val("gam")*%pi/180;
            H=get_gui_val("H");
            K=get_gui_val("K");
            L=get_gui_val("L");
            s_fac=get_gui_val("s_factor");

            if and([H,K,L]==[0,0,1]) then

                // determine reciprocal lattice vectors
                [SRAs,SRBs,SRCs]=reciprocal_lattice(a,b,c,alf,bet,gam,H,K,L,s_fac);

                // determine reciprocal surface unit cell       
                // -parallel components
                Aspar=[SRAs(1);SRAs(2)];
                Bspar=[SRBs(1);SRBs(2)];
                aspar=norm(Aspar);
                bspar=norm(Bspar);
                gamspar=acos((Aspar'*Bspar)/(aspar*bspar));

                // - perp components
                asperp=SRAs(3);
                bsperp=SRBs(3);
                csperp=SRCs(3);

                // display reciprocal space surface lattice
                set_gui_val("a",round(aspar*100)/100);
                set_gui_val("b",round(bspar*100)/100);
                set_gui_val("c",round(100*gamspar*180/%pi)/100);
                set_gui_val("alf",round(asperp*100)/100);
                set_gui_val("bet",round(bsperp*100)/100);
                set_gui_val("gam",round(csperp*100)/100);

                // set reciprocal space labels
                set_gui_txt("a_label","  aspar (1/nm)");
                set_gui_txt("b_label","  bspar (1/nm)");
                set_gui_txt("c_label","  gamspar (deg)");
                set_gui_txt("alf_label","  asperp (1/nm)");
                set_gui_txt("bet_label","  bsperp (1/nm)");
                set_gui_txt("gam_label","  csperp (1/nm)");

            else
                messagebox("switch to reciprocal lattice only for HKL=001");
                sg_info($)="real";
            end


        elseif sg_info($)=="real" then

            // get reciprocal space params
            aspar   = get_gui_val("a");
            bspar   = get_gui_val("b");
            gamspar = get_gui_val("c")*%pi/180;
            asperp = get_gui_val("alf");
            bsperp = get_gui_val("bet");
            csperp = get_gui_val("gam");

            // convert to real space params
            [a,b,c,alf,bet,gam] = real_lattice(aspar,bspar,gamspar,asperp,bsperp,csperp)

            // set real space params
            set_gui_val("a",round(a*100)/100);
            set_gui_val("b",round(b*100)/100);
            set_gui_val("c",round(c*100)/100);
            set_gui_val("alf",round(100*alf*180/%pi)/100);
            set_gui_val("bet",round(100*bet*180/%pi)/100);
            set_gui_val("gam",round(100*gam*180/%pi)/100);

            // surface unit cell from now on
            set_gui_val("H",0);
            set_gui_val("K",0);
            set_gui_val("L",1);
            set_gui_val("s_factor",1);

            // set real space labels
            set_gui_txt("a_label","  a (nm)");
            set_gui_txt("b_label","  b (nm)");
            set_gui_txt("c_label","  c (nm)");
            set_gui_txt("alf_label","  alf (deg)");
            set_gui_txt("bet_label","  bet (deg)");
            set_gui_txt("gam_label","  gam (deg)");

        else
            messagebox("typo in sg_info: use real or rec");
        end

    end

endfunction
