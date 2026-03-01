//
// calc_spots - 2X
//

// function
// - get xtal and beam parameters from GUI
// - calculate spot positions                 
// - plot spots
//
// dependencies:
// - called by "calc" pushbutton on main menu
// - calls reciprocal_lattice to switch to reciprocal mode
// - calls find_hkl to generate space group allowed hkl
// - calls plot_spots
// - returns plot_pars to main
//

function plot_pars=calc_spots(det_info,sg_info,plot_info)

    // scan type (area, GIRSM) and unit type (pixel, 1/nm)
    scan_type=det_info(2);
    unit_flag=evstr(det_info(17));

    // retrieve index rule
    index_rule=get_gui_item("index_rule");


    ///////////////////////////////////////////////////////////////////
    // retrieve input parameters from GUI
    
    // switch between real space and reciprocal space search
    search_mode=sg_info($)

    if search_mode=="real" then

        // get and convert lattice pars
        a=get_gui_val("a");
        b=get_gui_val("b");
        c=get_gui_val("c");

        alf=get_gui_val("alf")*%pi/180;
        bet=get_gui_val("bet")*%pi/180;
        gam=get_gui_val("gam")*%pi/180;

        // parallel plane index
        H=get_gui_val("H");
        K=get_gui_val("K");
        L=get_gui_val("L");

        // swelling or shrinkage factor
        s_fac=get_gui_val("s_factor");

        // reciprocal lattice vectors        
        [SRAs,SRBs,SRCs] = reciprocal_lattice(a,b,c,alf,bet,gam,H,K,L,s_fac)

    elseif search_mode=="rec" then

        // get and convert lattice pars
        aspar=get_gui_val("a");
        bspar=get_gui_val("b");
        gamspar=get_gui_val("c")*%pi/180;

        asperp=get_gui_val("alf");
        bsperp=get_gui_val("bet");
        csperp=get_gui_val("gam");

        // reciprocal surface unit cell
        SRAs=[aspar;0;asperp];
        SRBs=[bspar*cos(gamspar);bspar*sin(gamspar);bsperp];
        SRCs=[0;0;csperp];

    else
        messagebox("unknown search space");
    end

    ///////////////////////////////////
    // retrieving experiment parameters     

    alf_i  = get_gui_val("alf_i")*%pi/180;
    alf_cF = get_gui_val("alf_cF")*%pi/180;
    alf_cS = get_gui_val("alf_cS")*%pi/180;

    if scan_type=="area" then

        lambda   = get_gui_val("lambda");    
        L_SD     = get_gui_val("LSD_nu0");
        x_offset = get_gui_val("offset_nustep");
        x00      = get_gui_val("x0_del0");
        z0       = get_gui_val("z0_delstep");

        pixel_size = evstr(det_info(4))*evstr(det_info(10));  // include binning
        mpix = evstr(det_info(5));
        npix = evstr(det_info(6));
        x0 = x00 + x_offset/pixel_size;

        // conversion factors  
        dist_pix   = L_SD/pixel_size;
        pix_dist   = pixel_size/L_SD;

    elseif scan_type=="GIRSM" then      

        // retrieve set-up values  
        lambda = get_gui_val("lambda");    
        nu0    = get_gui_val("LSD_nu0");
        nustep = get_gui_val("offset_nustep");
        del0   = get_gui_val("x0_del0");
        delstep= get_gui_val("z0_delstep");

        mpix=evstr(det_info(5));
        npix=evstr(det_info(6));
        // messagebox("mpix,npix="+string(mpix)+", "+string(npix));

        // angle range of RSM
        numin=nu0;
        numax=(nu0+mpix*nustep);
        delmin=del0;
        delmax=(del0+npix*delstep);

        // alt - range given by plot menu:
        numin=get_gui_val("plot_xmin");
        numax=get_gui_val("plot_xmax");
        delmin=get_gui_val("plot_zmin");
        delmax=get_gui_val("plot_zmax");

        if nu0>numax-1 then
            error("pos3: bad nu range");
        end
        if del0>delmax-1 then
            error("pos4: bad del range")
        end

    else
        error("pos5: unknown scan_type: "+scan_type);
    end


    ///////////////////////////////////////////////////////////////////
    // calculating diffraction spots

    // vacuum wave vector
    k0=2*%pi/lambda;

    // limiting qz value as given by horizon
    qzlim=k0*sin(alf_i);

    // constants for final kf values - for "use units"
    ki0=(2*%pi/lambda);

    ///////////////////////////////////////////
    // generate all space-group allowed indices
    
    hkl = find_hkl(sg_info)

    // simplify
    hh=hkl(:,1);
    kk=hkl(:,2);
    ll=hkl(:,3);
    
    /////////////////////
    // calculate q-values
    
    qx = hh*SRAs(1) + kk*SRBs(1) + ll*SRCs(1);
    qy = hh*SRAs(2) + kk*SRBs(2) + ll*SRCs(2);
    Q = sqrt(qx .^ 2 + qy .^ 2);
    qz = hh*SRAs(3) + kk*SRBs(3) + ll*SRCs(3);
    qq  = sqrt(Q .^ 2 + qz .^ 2);
    // kludge for getting things to work: add As,Bs,Cs to reciprocal_lattice
    qq0 = qq; // meant to be hh*As+kk*Bs+ll*Cs for future powder ellipse module
    
    // clean up
    clear qx;
    clear qy;

    
    ///////////////////////////////////////////////////////////////////
    // scattering angle calculations
    
    // check whether "double vision" will occur    
    if (alf_i > alf_cF) & (alf_i < alf_cS) then
        refl_flag=1   // double vision
    else
        refl_flag=-1  // direct beam scatter
    end
    
    // clean and prepare output arrays
    spots = [];
    rspots = [];
    
    
    // begin double vision loop
    for refl=-1:2:refl_flag

        // refracted incident beam inside film (Busch et al, JApplCryst 2006]
        // all alfs are scalars, all bets are vectors
        alf_i2 = real(sqrt(sin(alf_i)^2 - sin(alf_cF)^2));
        // scattering inside film

        bet_f2 = real(asin(qz/k0 + refl*sin(alf_i2))); // "double vision"
        
        // refracted beam when exiting film
        bet_f  = real(asin(sqrt(sin(bet_f2) .^ 2 + sin(alf_cF)^2)));
        
        // in-plane scattering angle inside film
        theta_2 = asin(Q / (2*k0));    // in=plane Bragg angle of rod
        psi_2   = acos((cos(alf_i2)^2 + cos(bet_f2) .^ 2 - 4*sin(theta_2) .^2) ./ (2*cos(alf_i2) * cos(bet_f2)));
        
        // accept only reflections above horizon
        check = dfind(bet_f2 >= 0);   
        bet_f = bet_f(check);
        psi = real(psi_2);     // avoid imaginary psi
        psi = psi(check);
        
        // also reduce size of other saved values
        hh = hh(check);
        kk = kk(check);
        ll = ll(check);
        hkl = hkl(check,:)
        Q  = Q(check);
        qz = qz(check);
        qq = qq(check);
        qq0 = qq;
                
        // clean up memory
        clear bet_f2
        clear theta_2
        clear psi_2
        
        /////////////////////////////////////
        // transform to diffractometer angles

        // Detlef's exact fomula - power of indexing paper
        arg1 = sin(alf_i)*(cos(psi) .* cos(bet_f)) + cos(alf_i)*sin(bet_f);
        del  = asin(arg1);

        arg2 = sin(psi) .* cos(bet_f);
        arg3 = cos(alf_i)*(cos(psi) .* cos(bet_f)) - sin(alf_i)*sin(bet_f);
        nu   = atan(arg2,arg3);
        // note: atan(y,x):=atan(y/x) different from atan2
        
        // clean up memory
        clear arg1
        clear arg2
        clear arg3
        clear bet_f
        clear psi
        
        
        ///////////////////////////////////////////////////////////////
        // prepare output array according to scan type

        select scan_type
        case "GIRSM"

            // G2 RSM
            nudeg = nu*180/%pi;
            deldeg = del*180/%pi;

            if refl==-1 then              
                spots = [hh kk ll nudeg deldeg Q qz qq qq0];   // direct beam scatter
            elseif refl==1 then
                rspots = [hh kk ll nudeg deldeg Q qz qq qq0];   // "double vision"
            else
                error("undefined refl= "+string(refl));
            end

        case "area"
            // transform from angles to CCD pixels
            z = z0 + dist_pix * (tan(del) ./ cos(nu));  // raw image
            kfz = ki0*(z-z0)*pix_dist;                  // for "use units
            
            if sg_info(13)=="L" | sg_info(13)=="B" then
                x = x0 - dist_pix*tan(nu);      // left of beamstop
                kfx = ki0*(x-x0)*pix_dist;      // for "use units"
                if refl==-1 then              
                    spots = [spots; hh kk ll x z nu del Q qz qq qq0 kfx kfz];   // direct beam scatter
                else
                    rspots = [rspots; hh kk ll x z nu del Q qz qq qq0 kfx kfz];   // "double vision"
                end
            end

            if sg_info(13)=="R" | sg_info(13)=="B" then
                x = x0 + dist_pix*tan(nu);      // right of beamstop
                kfx = ki0*(x-x0)*pix_dist;      // for "use units"
                if refl==-1 then              
                    spots = [spots; hh kk ll x z nu del Q qz qq qq0 kfx kfz];   // direct beam scatter
                else
                    rspots = [rspots; hh kk ll x z nu del Q qz qq qq0 kfx kfz];   // "double vision"
                end
            end

        else
            error("pos6: bad scan_type: "+scan_type)
        end   // end G2/D1 switch

    end   // end double vision

    if size(spots,"r")==0 then
        // error("pos6: no spots in range")
        messagebox("pos7 warning: no spots in range")
    end


    ///////////////////////////////////////////////////////////////////
    // sort and save spots
    if scan_type=="area" then
        // numerical output
        // spots columns:
        // 1  2  3  4  5  6  7   8  9  10  11  12  13
        // hh kk ll x  z  nu del Q  qz qq  qq0 kfx kfz

        // sort spots by qq and write to file
        spots=sort_by_col(spots,10);    
        fprintfMat(TMPDIR+"\spots.dat",spots,"%f","spots.dat: h k l x z nu del Q qz q q0"); 

        if refl_flag==1 then
            // sort rspots by qq and write to file
            rspots=sort_by_col(rspots,10);
            fprintfMat(TMPDIR+"\rspots.dat",rspots,"%f","rspots.dat: h k l x z nu del Q qz q q0"); 
        end
        
    elseif scan_type=="GIRSM" then
        // numerical output - spots columns:
        // 1  2  3  4  5   6 7  8  9  
        // hh kk ll nu del Q qz qq qq0

        // sort spots by qq and write to file
        spots=sort_by_col(spots,8);    
        fprintfMat(TMPDIR+"\spots.dat",spots,"%f","spots.dat: h k l nu del Q qz q q0"); 
        if refl_flag==1 then
            // sort rspots by qq and write to file
            rspots=sort_by_col(rspots,8);
            fprintfMat(TMPDIR+"\rspots.dat",rspots,"%f","rspots.dat: h k l nu del Q qz q q0");
        end
    else
        error("pos8:unknown scan type");
    end


    // plot parameters for scattering features (horizon, Yoneda band, beam, reflected beam)

    // special z positions (pixels)
    if scan_type=="area" then
        plot_pars=[];
        xmin=1;
        xmax=mpix;
        zR =z0+dist_pix*tan(2*alf_i);         // refl
        zH =z0+dist_pix*tan(alf_i);           // horizon
        zYF=z0+dist_pix*tan(alf_i+alf_cF);    // film Yoneda
        zYS=z0+dist_pix*tan(alf_i+alf_cS);    // substrate Yoneda        
        if unit_flag==0 then
            plot_pars=[x0,xmin,xmax,z0,zR,zH,zYF,zYS,refl_flag];
        elseif unit_flag==1 then
            kfmin =ki0*(1-x0)   *pix_dist;
            kfmax =ki0*(mpix-x0)*pix_dist;
            kfR   =ki0*(zR-z0)  *pix_dist;
            kfH   =ki0*(zH-z0)  *pix_dist;
            kfYF  =ki0*(zYF-z0) *pix_dist;
            kfYS  =ki0*(zYS-z0) *pix_dist;
            plot_pars=[kfmin,kfmax,kfH,kfR,kfYF,kfYS,refl_flag];
        else
            error("calc_spots: unit_flag undefined"+string(unit_flag));
        end
    elseif scan_type=="GIRSM" then
        plot_pars=[];
        plot_pars=[nu0,nustep,alf_cF,alf_i,refl_flag];
    else
        messagebox("pos9: unknown scan_type: "+scan_type);
    end


    ///////////////////////////////////////////////////////////////////
    // overlay calculated spots to detector image
    
    plot_spots(det_info,plot_info,plot_pars);

endfunction
