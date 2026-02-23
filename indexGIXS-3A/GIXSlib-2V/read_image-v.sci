//
// read image R
//

// added flags flip (tb/lr) and rotate (cw/ccw) to det_info
// - revamp read making better use of det_info
// - only need read cases for scan_type "area" and "GIRSM"
// - prepared nbin value for binned images

function [mat,det_info]=read_image(det_info)  //plot-area

    // debug on/off
    debug_flag=%f;

    // unpack det_info
    det_make=det_info(1);
    scan_type=det_info(2);
    det_type=det_info(3);
    pixel_size=evstr(det_info(4));
    npix=evstr(det_info(5));
    nlines=evstr(det_info(6));
    header_bytes=evstr(det_info(7));
    fmt=det_info(8);
    ext=det_info(9);
    nbin=evstr(det_info(10));
    rot_mode=det_info(11);
    flip_mode=det_info(12);

    // open file and remember data path
    [x,err]=fileinfo(TMPDIR+"\path.par");

    if err<0
        path="c:\";
    else      
        path=mgetl(TMPDIR+"\path.par");     // retrieve previous path
    end

    filename=uigetfile(ext,path);           // get filename
    
    // check header_bytes for custom format 
    // (ALS,SAXSLAB,Bruker,Albula,CMS,OPLS,AS)
    fi=fileinfo(filename);
    
    // list of custom Pilatus formats
    custom_list=["Pilatus 1M cms","Pilatus 2M cms"];
    custom_list=[custom_list,"Pilatus 1M gb","Pilatus2M gb"];
    custom_list=[custom_list,"Ganesha 300k"];
    
    // disp(det_type)
    
    if or(det_type == custom_list) then
        // disp("custom fmt")
        nlen=4;   // 32-bit  or 4-byte float (GB format)
        imbytes=fi(1)-npix*nlines*nlen;
        if header_bytes<>imbytes then
            header_bytes=imbytes;
            // kludge - this only works, if tiff file ends with image
            // note - not the case for original Dectris format!
            // these det_types are nonstandard, processed tiff
        end
    end
    
    // Xenocs/ESRF EDF format with ASCII header
    if det_type == "Xenocs EDF" then        
        
        // read ASCII header
        fd = mopen(filename);
        txt = mgetl(fd,68);
        mclose(fd);

        // detector parameters
        line=grep(txt,"EDF_BinarySize")
        nbytes = evstr(tokens(txt(line))(3))
        // disp("nbytes",nbytes)
        line=grep(txt,"EDF_HeaderSize")
        header_bytes = evstr(tokens(txt(line))(3))
        // disp("header bytes",header_bytes)
        line=grep(txt,"Dim_1")
        npix = evstr(tokens(txt(line))(3))
        // disp("npix",npix)
        line=grep(txt,"Dim_2")
        nlines = evstr(tokens(txt(line))(3))
        // disp("nlines",nlines)

        if npix*nlines*4 ~= nbytes then
            messagebox("error in EDF header");
        end
        
        // update det_info (maybe obsolete)
        det_info(5)=string(npix);
        det_info(6)=string(nlines);
        det_info(7)=string(header_bytes);

        // experiment parameters
        line=grep(txt,"Center_1");
        x0 = evstr(tokens(txt(line))(3));
        x0 = x0/nbin             // for binning
        set_gui_val("x0_del0",x0);
        // disp("x0",x0)
        line=grep(txt,"Center_2");
        z0 = evstr(tokens(txt(line))(3));
        z0 = (nlines-z0)/nbin    // flip tb and binning
        set_gui_val("z0_delstep",z0);
        // disp("z0",z0)
        line=grep(txt,"PSize_1");
        pixel_size = evstr(tokens(txt(line))(3))*1000;
        det_info(4) = string(pixel_size);
        // disp("pixel_size",pixel_size)
        line=grep(txt,"SampleDistance");
        LSD = evstr(tokens(txt(line))(3))*1000;
        set_gui_val("LSD_nu0",LSD)
        // disp("LSD",LSD)
        line=grep(txt,"Wavelength");
        lambda = evstr(tokens(txt(line))(3))*1e9;
        set_gui_val("lambda",lambda);
        // disp("lam",lam)
        line=grep(txt,"om =");
        alf_i = evstr(tokens(txt(line))(3));
        set_gui_val("alf_i",alf_i);
        // disp("alfi",alfi)

    end

    
    
    // update path of image directory
    if filename<>"" then
        path=fileparts(filename);           // extract the path
        mputl(path,TMPDIR+"\path.par");     // remember current path

        // read status
        set_gui_txt("read_status","-- reading file --");


        /////////////////////////////////////////////////////////////
        // binary read from TIFF data file (area)
        // or mat read from ASCII (GIRSM)
        /////////////////////////////////////////////////////////////

        // area detectors
        if scan_type=="area" then
            if det_make=="matrix" then
                fd=mopen(filename,"rb");
                npix=mget(1,"i");
                nlines=mget(1,"i");
                x=mgeti(npix*nlines,"i");
                mclose(fd);
                aux=matrix(x,npix,nlines);
                clear x;
                det_info(5)=string(npix);
                det_info(6)=string(nlines);
            else
                fd=mopen(filename,"rb");
                if header_bytes>0 then
                    mseek(header_bytes,fd);
                end
                nbytes=npix*nlines;
                if fmt=="f" then
                    x=mget(nbytes,"f",fd);
                    x=int16(x);
                else
                    x=mgeti(nbytes,fmt,fd);      // very fast read of image
                end
                mclose(fd);

                if nbin==1 then
                    aux=matrix(x,npix,nlines);   // very fast reformat of image
                    clear x;                     // free memory
                else
                    // original image matrix
                    b=matrix(x,npix,nlines);
                    clear x;

                    // trim b, if npix, nlines not divisible by nbin
                    if pmodulo(npix,nbin)<>0 | pmodulo(nlines,nbin)<>0 then
                        npix=floor(npix/nbin)*nbin;
                        nlines=floor(nlines/nbin)*nbin;
                        nbytes=npix*nlines;
                        a=b(1:npix,1:nlines);
                        clear b;
                        b=a;
                        clear a;
                    end

                    // fast binning
                    c=matrix(b,nbin,nbytes/nbin)/nbin;
                    clear b;
                    d=sum(c,"r");
                    clear c;
                    f=matrix(d,npix/nbin,nlines)';
                    clear d;
                    g=matrix(f,nbin,nbytes/nbin/nbin)/nbin;
                    clear f;
                    h=sum(g,"r");
                    clear g;
                    aux=matrix(h,nlines/nbin,npix/nbin)';
                    clear h;
                    // end binning
                end
            end

            // image orientation - a bit awkward, but easy to grasp
            select rot_mode
            case "ccw"
                mat=aux';
                aux=mat;
                [m n]=size(aux);
                mat=aux(m:-1:1,:);
                aux=mat;
            case "cw"
                mat=aux';
                aux=mat;
                [m n]=size(aux);
                mat=aux(:,n:-1:1);
                aux=mat;
            case "180"
                [m n]=size(aux);
                mat=aux(:,n:-1:1);
                aux=mat;
                mat=aux(m:-1:1,:);
                aux=mat;
            else
                mat=aux;    // ensure that mat is assigned something
            end

            select flip_mode
            case "tb"
                [m n]=size(aux);
                mat=aux(:,n:-1:1);          // flip top-bottom
            case "lr"
                [m n]=size(aux);
                mat=aux(m:-1:1,:);          // flip left-right
            end

            // more efficient: flip diagonal/left-right/top-bottom
            // generate all 8 pssibilities (000 to 111, commutative)
            // if flip_diag then
            //     mat=aux';
            //     aux=mat;
            // end
            // if flip_lr then
            //     [m n]=size(aux);
            //     mat=aux(m:-1:1,:);
            //     aux=mat;
            // end
            // if flip_tb then
            //     [m n]=size(aux);
            //     mat=aux(:,n:-1:1);
            //     aux=mat;
            // end

            clear aux;  // free memory

            // ASCII read from G2 file (*array.txt, *.mat)
        elseif scan_type=="GIRSM" then
            
            //[aux text]=fscanfMat(filename); // dnw sometimes
            [aux text]=read_Mat(filename);    // patch
            mat=aux';
            clear aux;
            [m n]=size(mat);
            mat=mat(:,n:-1:1);
            det_info(5)=string(m); // points per line
            det_info(6)=string(n); // lines

            if debug_flag then
                messagebox(det_make);
            end

            if det_make=="HERMES diode array - cal" then
                // evaluate text
                
                // - channel number
                aux=[];
                aux=tokens(text(1));
                if debug_flag then
                    messagebox(aux);
                end
                Nch=evstr(aux(8));

                // - nu range
                aux=[];
                aux=tokens(text(2));
                if aux(4)<>"nu" then
                    messagebox(["note: no nu scan",aux(4)+" scan"],"warning");
                end
                nu0=evstr(aux(5));
                nustep=(evstr(aux(6))-nu0)/evstr(aux($-1));  // $ is the last element

                // - proper axes names based on header
                my_axes=findobj("user_data","intensity");
                my_axes.x_label.text=aux(4)+" (deg)";

                // - del calibration / HERMES diode array
                aux=[];
                aux=tokens(text(3));
                delstep=abs(evstr(aux(9)));
                del0=evstr(aux(8))-Nch*delstep;

                // - process monitor data
                aux=[];
                aux=tokens(text(5));
                len=max(size(aux));
                mon=evstr(aux(2:len));
                mon=mon/mon(1);
                // if debug_flag then
                //    messagebox(string(mon),"monitor");
                // end

                // - normalize data
                for i=1:m
                    mat(i,:)=mat(i,:)/mon(i);
                end

                // update GUI values
                set_gui_val("LSD_nu0",nu0);
                set_gui_val("offset_nustep",nustep);
                set_gui_val("x0_del0",del0);
                set_gui_val("z0_delstep",delstep);
            end

            // warning message
        else
            messagebox("unknown detector format","warning");
        end

        // read status
        set_gui_txt("read_status",filename);

    else
        set_gui_txt("read_status","-- no file read --");
        messagebox("warning: no file read");
        mat=[];
    end

endfunction
