//////////////////////////////////////////////////////
// design main window - scilab-6.n

//
// construct new window
//

// note: can be tested stand-alone using F5 after running gui_param
// - get screen size
screen=get(0,"screensize_px");
screenH=screen(3);
screenV=screen(4);

if screenV>900 then
    version="indexGIXS 2U for desktop    (c) Detlef Smilgies 2021-2026";
else
    version="indexGIXS 2U for laptop     (c) Detlef Smilgies 2021-2026";
end

version=getversion();
yr=evstr(part(version,8:11));

level_num=32;   // fixed for now to work with decode fcns
my_win=figure(5,"figure_name",version,...
                "figure_size",[winw+20,winh+20],...
                "figure_position",[0,0],...
                "background",-2,...
                "tag","main_window");
                
                
// my_win.menubar_visible="off";
my_win.toolbar_visible="off";
my_win.infobar_visible="off";
                

//
// lay out plot window
//

// dummy plot to define plot area

drawlater;   // avoid flicker while object properties are reset

  // set the colormap            
  // my_win.color_map=jetcolormap(level_num);    // MatLab-style colormap
  // add primary colors for plot symbols
  primary=[0,0,0;1,0,0;0,1,0;0,0,1;0,1,1;1,0,1;1,1,0;1,1,1];
  
  level_num=32;   // level_num fixed at 32 for decode fcns
  
  if yr<2025 then
    my_win.color_map=[jetcolormap(level_num);primary];
  else
    // starting with scilab-2025 jetcolormap >>> jet
    my_win.color_map=[jet(level_num);primary];
  end
  
  my_win.background=-2;                       // default background - white
  
  // define upper plot area - intensity map
  subplot(1,2,1);
  
  my_axes=gca();
  my_axes.user_data="intensity";
  // confine plot to part of window
  my_axes.axes_bounds=[0.0,0.0,0.7,0.72];    // left, top, width, hite
  my_axes.auto_scale="off";
  my_axes.data_bounds=[0 0;1000 1000];
  my_axes.tight_limits="on";
  my_axes.font_size=2;
  my_axes.x_label.font_size=3;
  my_axes.y_label.font_size=3;
  my_axes.x_label.text="x (pixel)";
  my_axes.y_label.text="z (pixel)";
  
  // dummy plot
  plot(0,0,".");
  
  // define lower plot area - horizontal colorbar
  subplot(1,2,2);
  my_bar=gca();
  my_bar.user_data="colorbar";
  my_bar.axes_bounds=[0.05,0.72,0.6,0.03];   // left,top,width,hite
  
  my_colorbar(level_num,0,level_num,0);      // default range: level_num

  my_bar.axes_visible=["on","off","off"];
  my_bar.x_location="bottom";
  my_bar.font_size=2;
  // my_bar.x_label.font_size=3;
  // my_bar.x_label.text="intensity (arb. units)";
drawnow;
