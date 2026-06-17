// dlib > plot > own colorbar with log

function my_colorbar(nlevel,zmin,zmax,log_flag)
    // horizontal lin/log colorbar for intensity a la fit2d

    // calculate parameters of colorbar
    if log_flag==1 then
        logzmin=log10(zmin);
        logzmax=log10(zmax);
        logstep=(logzmax-logzmin)/nlevel;
        t=0:nlevel;
        x=10.^(logzmin+t*logstep);
        y=[0:1];
    elseif log_flag==0 then
        t=0:nlevel;
        x=zmin+t*(zmax-zmin)/nlevel;
        y=[0:1];
    else
        error("my_colorbar: unknown log_flag: "+string(log_flag));
    end
    z=[];  // important when changing nlevel
    z(:,1)=[0:nlevel]';
    z(:,2)=z(:,1);

    drawlater;

    // identify window and subplot
    a=findobj("user_data","colorbar");
    sca(a);

    // graphics settings
    set(a,"tight_limits","on");
    if log_flag==1 then
        if zmin<=0 then
            zmin=1;
        end
        if zmax<=0 then
            zmax=10000;
        end
        // tracing error - undo later
        set(a,"data_bounds",[zmin,0;zmax,1]);
        set(a,"log_flags","lnn");
    else
        set(a,"data_bounds",[zmin,0,0;zmax,1,1]);
        set(a,"log_flags","nnn");
    end

    // plot color scale
    h_colorscale=findobj("user_data","colorscale");
    if h_colorscale==[] then
        grayplot(x,y,z);
        h_colorscale=gce();
        h_colorscale.user_data="colorscale";
    else
        h_colorscale.data.x=x';
        h_colorscale.data.z=z;
    end
    h_colorscale.data_mapping="direct";

    // overwrite default
    set(a,"axes_visible",["on","off","on"]);

    drawnow;

endfunction
