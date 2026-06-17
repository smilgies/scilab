function plot_ROI()
  
  // get ROI values and ISO flag
  
  xmin=get_gui_val("plot_xmin");
  xmax=get_gui_val("plot_xmax");
  zmin=get_gui_val("plot_zmin");
  zmax=get_gui_val("plot_zmax");
  iso_flag=get_gui_menu("iso_flag");
  
  // get figure and axes handle  
  my_axes=findobj("user_data","intensity");
  sca(my_axes);
  
  // rescale plot axes
  my_axes.auto_scale="off";
  my_axes.data_bounds=[xmin zmin;xmax zmax];

  if iso_flag then
      my_axes.isoview="on";
  else
      my_axes.isoview="off";
  end
  
endfunction
