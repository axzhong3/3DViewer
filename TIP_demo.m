% CS280, Computer Vision, Tour Into the Picture
% HW1, Sample startup code by Alyosha Efros (so it's buggy!)
%
% We read in an image, get the 5 user-speficied points, and find
% the 5 rectangles.  

% read in sample inage
im = imread('sample.jpg');

% resize image for faster processing
im = imresize(im, 0.5);

% Run the GUI in Figure 1
figure(1);
[vx,vy,irx,iry,orx,ory] = TIP_GUI(im);

% Find the cube faces and compute the expended image
[bim,bim_alpha,vx,vy,ceilrx,ceilry,floorrx,floorry,...
    leftrx,leftry,rightrx,rightry,backrx,backry] = ...
    TIP_get5rects(im,vx,vy,irx,iry,orx,ory);

% display the expended image
figure(2);
imshow(bim);
% Here is one way to use the alpha channel (works for 3D plots too!)
%%alpha(bim_alpha);

% Draw the Vanishing Point and the 4 faces on the image
figure(2);
hold on;
plot(vx,vy,'w*');
plot([ceilrx ceilrx(1)], [ceilry ceilry(1)], 'y-');
plot([floorrx floorrx(1)], [floorry floorry(1)], 'm-');
plot([leftrx leftrx(1)], [leftry leftry(1)], 'c-');
plot([rightrx rightrx(1)], [rightry rightry(1)], 'g-');
hold off;

%% Generate fronto-parallel views of each plane

xmin = min([ceilrx(1) floorrx(4) leftrx(1)]);
xmax = max([ceilrx(2) floorrx(3) rightrx(3)]);
ymin = min([leftry(1) rightry(2) ceilry(1)]);
ymax = max([leftry(4) rightry(3) floorry(3)]);

destn = [xmin xmax xmax xmin; ymin ymin ymax ymax];

% Calculate 3D dimension
sim_trig_ratio = sqrt((xmax-xmin)*(ymax-ymin)/((backrx(2)-backrx(1))*(backry(3)-backry(2))));
focal_length = 1500;
%focal_length = max(backrx(2)-backrx(2),backry(3)-backry(2))/2/tan(pi/180*30/2);
depth = focal_length*(sim_trig_ratio-1);

%% transform of the image
source_ceil = [ceilrx; ceilry];
[h_ceil,t_ceil] = computeH(source_ceil, destn);
ceil = imtransform(bim, t_ceil, 'xData',[xmin xmax],'yData',[ymin ymax]);
% figure(3); imshow(ceil); axis image;

source_floor = [floorrx; floorry];
[h_floor,t_floor] = computeH(source_floor, destn);
floor = imtransform(bim, t_floor, 'xData',[xmin xmax],'yData',[ymin ymax]);
% figure(4); imshow(floor); axis image;

source_back = [backrx; backry];
[h_back,t_back] = computeH(source_back, destn);
back = imtransform(bim, t_back, 'xData',[xmin xmax],'yData',[ymin ymax]);
alpha_b = ones(size(back,1),size(back,2));
% figure(5); imshow(back); axis image;

source_left = [leftrx; leftry];
[h_left,t_left] = computeH(source_left, destn);
left = imtransform(bim, t_left, 'xData',[xmin xmax],'yData',[ymin ymax]);
% figure(6); imshow(left); axis image;

source_right = [rightrx; rightry];
[h_right,t_right] = computeH(source_right, destn);
right = imtransform(bim, t_right, 'xData',[xmin xmax],'yData',[ymin ymax]);
% figure(7); imshow(right); axis image;


%% sample code on how to display 3D sufraces in Matlab
% define a surface in 3D (need at least 6 points, for some reason)

ceil_planex = [0 0 0; depth depth depth];
ceil_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
ceil_planez = [ymax ymax ymax; ymax ymax ymax];

floor_planex = [depth depth depth; 0 0 0];
floor_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
floor_planez = [ymin ymin ymin; ymin ymin ymin];

back_planex = [depth depth depth; depth depth depth];
back_planey = [xmin (xmax+xmin)/2 xmax; xmin (xmin+xmax)/2 xmax];
back_planez = [ymax ymax ymax; ymin ymin ymin];

left_planex = [0 depth/2 depth; 0 depth/2 depth];
left_planey = [xmin xmin xmin; xmin xmin xmin];
left_planez = [ymax ymax ymax; ymin ymin ymin];

right_planex = [depth depth/2 0; depth depth/2 0];
right_planey = [xmax xmax xmax; xmax xmax xmax];
right_planez = [ymax ymax ymax; ymin ymin ymin];

% create the surface and texturemap it with a given image

view = figure('name','3DViewer: Directions[W-S-A-D] Zoom[Q-E] Exit[ESC]');
set(view,'windowkeypressfcn','set(gcbf,''Userdata'',get(gcbf,''CurrentCharacter''))') ;
set(view,'windowkeyreleasefcn','set(gcbf,''Userdata'','''')') ;
set(view,'Color','black')
hold on
warp(ceil_planex,ceil_planey,ceil_planez,ceil);
warp(floor_planex,floor_planey,floor_planez,floor);
warp(back_planex,back_planey,back_planez,back);
warp(left_planex,left_planey,left_planez,left);
warp(right_planex,right_planey,right_planez,right);

% Beware that matlab has 2 axis modes, ij ans xy, be sure to check if you are using
% the right one if you get flipped results.

% fly-through matrix
keys = [
   101    7;
    97     1;
   100     1;
   101    26;
    97   175;
   100   320;
    97   161;
   115    89;
   119   180;
   115   104;
   100    18;
   101     1;
   113    22;
    97    94;
    28    95;
    30    54;
    29   114;
   100   168;
    31    15;
   100     1;
    31    37;
   100    38;
    29    49;
    31    53;
   100    22;
    29    57;
    30    59;
    97    24;
    31    23;
   101     1;
   113    12;
    28    28;
    31    40;
    97    32;
    28   178;
    97    65;
   101     1;
   113     9;
    31     4;
    97    19;
    31    90;
    97   50;
];


% Some 3D magic...
axis equal;  % make X,Y,Z dimentions be equal
axis vis3d;  % freeze the scale for better rotations
axis off;    % turn off the stupid tick marks
camproj('perspective');  % make it a perspective projection

% set camera position
camx = -1719.8;
camy = 1345;
camz = 858.8;

% set camera target
tarx = 228.5;
tary = 1312;
tarz = 817.5;

% set camera step
stepx = 0.05;
stepy = 0.05;
stepz = 0.05;

% set camera on ground
camup([0,0,1]);
campos([camx camy camz]);

for index = 1:size(keys,1)
	count = keys(index,2);
	while (count > 0),
    
		switch keys(index,1),
			case 'd'
				camdolly(-stepx,0,0,'fixtarget');
			case 'a'
				camdolly(stepx,0,0,'fixtarget');
			case 's'
				camdolly(0,stepy,0,'fixtarget');
			case 'w'
				camdolly(0,-stepy,0,'fixtarget');
			case 'q'
				camdolly(0,0,stepz,'fixtarget');
			case 'e'
				camdolly(0,0,-stepz,'fixtarget');
			case 28
				campan(-0.1,0);
			case 29
				campan(0.1,0);
			case 30
				campan(0,0.1);
			case 31
				campan(0,-0.1);
			case 13
				break;
			case 27
				break;
			case 'p'
				break;
		end
    
    count=count-1;

    pause(.0001);
    
	end;
end	

key = 0;

while (~key),
    waitforbuttonpress;
    key = get(view, 'currentch');
    
    switch key
        case 'd'
            camdolly(-stepx,0,0,'fixtarget');
        case 'a'
            camdolly(stepx,0,0,'fixtarget');
        case 's'
            camdolly(0,stepy,0,'fixtarget');
        case 'w'
            camdolly(0,-stepy,0,'fixtarget');
        case 'q'
            camdolly(0,0,stepz,'fixtarget');
        case 'e'
            camdolly(0,0,-stepz,'fixtarget');
        case 28
            campan(-0.1,0);
        case 29
            campan(0.1,0);
        case 30
            campan(0,0.1);
        case 31
            campan(0,-0.1);
        case 13
            break;
        case 27
            break;
        case 'p'
            break;
    end
    
    key = 0;

    pause(.001);

    %campos([camx camy camz]);
    %camtarget([tarx tary tarz]);
    pos = campos;
    target = camtarget;
    
end;
delete(view);
% set camera target
% camtarget([0,0,0.5])
% use the "rotate 3D" button on the figure or do "View->Camera Toolbar"
% to rotate the figure
% or use functions campos, camtarget, camup to set camera location 
% and viewpoint from within Matlab code
