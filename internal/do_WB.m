function IMGWB = do_WB(IMG, WP)

% IMG = double(IMG1x);
% WP = WP1x;

IMG = double(IMG);

IMG2D = reshape(IMG, [], size(IMG,3));

IMG2DWB = IMG2D./WP;

IMGWB = reshape(IMG2DWB, size(IMG,1), size(IMG,2), size(IMG,3));

end