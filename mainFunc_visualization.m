%{
it is for visualization

One essential data not available here
the QE curves of main and telephoto camera
%}

clc;
clear all;
close all;

addpath('./data/')
addpath('./imgsIllustration/')
addpath('./internal/')

%% load image
% absolute path, instead relative path
exifToolPath = 'E:\Windows_C\Desktop\Code\data\exiftool.exe';
dcrawPath = './';
imagePath = 'E:\Windows_C\Desktop\Code\imgsIllustration';

SceneName = 'DJI_20231209';

Name1x = strcat(SceneName,'1x');
Name3x = strcat(SceneName,'3x');
imageName1x = strcat(SceneName,'1x.DNG');
imageName3x = strcat(SceneName,'3x.DNG');

IMG1xRaw = load(strcat(imagePath,'\',Name1x,'.mat')).IMG1xRaw;
DataET1x = read_MetaDatabyExifTool(imagePath,imageName1x,exifToolPath);

IMG3xRaw = load(strcat(imagePath,'\',Name3x,'.mat')).IMG3xRaw;
DataET3x = read_MetaDatabyExifTool(imagePath,imageName3x,exifToolPath);

IMG1xRawCrop = IMG1xRaw(round(size(IMG1xRaw,1)*(1/3))+1:round(size(IMG1xRaw,1)*(2/3)),round(size(IMG1xRaw,2)*(1/3))+1:round(size(IMG1xRaw,2)*(2/3)),:);

IMG1xRawCrop = imresize(IMG1xRawCrop,0.75); 
IMG3xRaw = imresize(IMG3xRaw,0.33); 


%% uint16 -> double and extract WP in DNG
IMG1xRaw = double(IMG1xRaw)./(2^16-1);
IMG1xRawCrop = double(IMG1xRawCrop)./(2^16-1);
IMG3xRaw = double(IMG3xRaw)./(2^16-1);

% convert_str2double4WP.m because WP is saved as string
WP1x = convert_str2double4WP(DataET1x.AsShotNeutral);
WP3x = convert_str2double4WP(DataET3x.AsShotNeutral);

clear DataET1x DataET3x

%% load results based on mainFunc.m
data = load('./data/Results.mat');
ArrayIllum = data.ArrayIllum;
SPDLab = data.SPDLab;
LisInputInter = data.LisInputInter;
clear data

MGeneral = zeros(size(LisInputInter,1),size(LisInputInter,2));

for m = 1:size(LisInputInter,1)
    for n = 1:size(LisInputInter,2)
        [unique_elements, ~, idx] = unique(squeeze(LisInputInter(m,n,:)));
        element_counts = accumarray(idx, 1);
        [~, IdxMax] = max(element_counts);
        MGeneral(m,n) = unique_elements(IdxMax);
    end
end

IllumFreq = zeros(size(ArrayIllum,1),size(ArrayIllum,2));
for i = 1:size(ArrayIllum,1) % every interval/interpolation
    for j = 1:size(ArrayIllum,2)
        ArrayIllumTemp = ArrayIllum(i,j,:); 
        ArrayIllumTemp = ArrayIllumTemp(:);
        [unique_elements, ~, idx] = unique(ArrayIllumTemp);
        element_counts = accumarray(idx, 1);
        [~, idxMax] = max(element_counts);
        IllumFreq(i,j) = unique_elements(idxMax);
    end
end

SPDSelect = SPDLab(:,unique(IllumFreq));
IdxSPDSelect = zeros(size(IllumFreq));
for m = 1:size(IllumFreq,1)
    for n = 1:size(IllumFreq,2)
        IdxSPDSelect(m,n) = find(unique(IllumFreq)==IllumFreq(m,n));
    end
end

%% QE curves is not public, the necessary data precalculated and save
% WPsTrain1x = SPDSelect'*CSSs1x;
% WPsTrain3x = SPDSelect'*CSSs3x;

WPsTrain1x = load('./data/WPsTrain1x.mat').WPsTrain1x;
WPsTrain3x = load('./data/WPsTrain3x.mat').WPsTrain3x;

WPsTrain1xNorm = WPsTrain1x./WPsTrain1x(:,2);
WPsTrain3xNorm = WPsTrain3x./WPsTrain3x(:,2);

MGMWP = pinv(WPsTrain1xNorm)*WPsTrain3xNorm;

WP3xEst = (WP1x./WP1x(2))*MGMWP;
WP3xEst = WP3xEst./WP3xEst(2);

%% visulaiztion (vector plot in Subject Test in paper)
close all;
figure;
quiver(WPsTrain1xNorm(:,1)./sum(WPsTrain1xNorm,2),WPsTrain1xNorm(:,3)./sum(WPsTrain1xNorm,2),(WPsTrain3xNorm(:,1)./sum(WPsTrain3xNorm,2))-(WPsTrain1xNorm(:,1)./sum(WPsTrain1xNorm,2)),(WPsTrain3xNorm(:,3)./sum(WPsTrain3xNorm,2))-(WPsTrain1xNorm(:,3)./sum(WPsTrain1xNorm,2)),'AutoScale','off');
hold on;
quiver(WP1x(1)./sum(WP1x),WP1x(3)./sum(WP1x),(WP3x(1)./sum(WP3x))-(WP1x(1)./sum(WP1x)),(WP3x(3)./sum(WP3x))-(WP1x(3)./sum(WP1x)),'--r','LineWidth',1.5);
hold on;
quiver(WP1x(1)./sum(WP1x),WP1x(3)./sum(WP1x),(WP3xEst(1)./sum(WP3xEst))-(WP1x(1)./sum(WP1x)),(WP3xEst(3)./sum(WP3xEst))-(WP1x(3)./sum(WP1x)),':m','LineWidth',1.5);
xlabel('$\frac{R}{R+G+B}$','Interpreter','latex','FontSize',14);
ylabel('$\frac{B}{R+G+B}$','Interpreter','latex','FontSize',14);
legend({'Training','Original','Converted'},'FontSize',10);

%% Visualization Image
IMG1xRawWB = do_WB(IMG1xRaw, WP1x);
IMG1xRawCropWB = do_WB(IMG1xRawCrop, WP1x);
IMG3xRawWB = do_WB(IMG3xRaw, WP3x);
IMG3xRawWBEst = do_WB(IMG3xRaw, WP3xEst);

% visualization in Raw with WB
figure;
imshow(power(IMG1xRawWB*0.2/mean(IMG1xRawWB(:,:,2),'all'),1/2.4));
title('IMG1x(Initial)');

figure;
imshow(power(IMG1xRawCropWB*0.2/mean(IMG1xRawCropWB(:,:,2),'all'),1/2.4));
title('IMG1x(Cropped)');

figure;
imshow(power(IMG3xRawWB*0.2/mean(IMG3xRawWB(:,:,2),'all'),1/2.4));
title('IMG3x(Initial)');

figure;
imshow(power(IMG3xRawWBEst*0.2/mean(IMG3xRawWBEst(:,:,2),'all'),1/2.4));
title('IMG3x(1xWP)');
