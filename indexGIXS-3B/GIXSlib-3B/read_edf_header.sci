function [npix,nlines,header_bytes,pixel_size]=read_edf_header(filename,nbin)
    
    // reading Xenocs-style EDF file header
              
    // read ASCII header
    fd = mopen(filename);
    txt = mgetl(fd,100);
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
    line=grep(txt,"PSize_1");
    pixel_size = evstr(tokens(txt(line))(3))*1000;

    // check EDF header info
    if npix*nlines*4 ~= nbytes then
        messagebox("error in EDF header");
    end

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

endfunction

