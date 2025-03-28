%{
the turtorial pf the demo code.
R. HE, M. WEI, "Cross-camera correction for color constancy, Part 1:
alignment white point,"

Difference between demo code and paper result:
the SPDs Dataset differes
you can check the following cell/section "import SPD dataset"
%}

clear all
clc
close all

%% add path
addpath('./internal');
addpath('./camera_spectral');
addpath('./data')

%% import SPD dataset
%{
SPD dataset from
Barnard, Kobus et al. 
“A data set for color research.” 
Color Research and Application 27 (2002): 147-151.
%}

% the visible spectrum [380:4:780]
SPDtri = load('illum_train.txt');
SPDtri = reshape(SPDtri, 101, length(SPDtri)/101);
SPDtst = load('illum_test.txt');
SPDtst = reshape(SPDtst, 101, length(SPDtst)/101);

SPDLab = cat(2, SPDtri, SPDtst);
SPDLab = interp1([380:4:780], ...
    SPDLab, ...
    [400:10:700]);

clear SPDtri SPDtst

%% pair up these 28 cameras to form camera pairs
combCam2 = combnk(1:28, 2);
combCam2inverse = combCam2(:,[2 1]);
combCam2 = [combCam2;combCam2inverse];
clear combCam2inverse

CellCams = {'Canon1D Mark III','Canon5D Mark II','Canon20D','Canon40D',...
    'Canon50D','Canon60D','Canon300D','Canon500D','Canon600D','Hasselblad',...
    'Nikon3dx','NikonD3','NikonD40','NikonD50','NikonD80','NikonD90',...
    'NikonD200','NikonD300s','NikonD700','NikonD5100','NokiaN900',...
    'OlympusEPL2','PentaxK5','PentaxQ','Phase One','PointGreyGrasshopper',...
    'PointGreyGrasshopper2','SonyNex5N'};

%% loop for all camera pairs (find representative SPDs set for each pair)
LisVora = zeros(size(combCam2,1),1);
LisName = cell(size(combCam2));
NumCSSCam1 = 3;
NumCSSCam2 = 3;
LisInputInter = zeros(NumCSSCam1,NumCSSCam2,size(combCam2,1));
numInterval = 10;
ArrayIllum = zeros(numInterval,2,size(combCam2,1));

if exist('./data/Results.mat', 'file') > 0
    bool_exist = true;
else
    bool_exist = false;
end

if ~bool_exist
    % it takes 30 mins or so
    for NoComb = 1:size(combCam2,1)
        fprintf('%d/%d starts.\n',NoComb,size(combCam2,1));
        
        % load the information you need (CSSs of main and telephoto camera)
        NameCam1 = char(CellCams(combCam2(NoComb,1)));
        NameCam2 = char(CellCams(combCam2(NoComb,2)));
        infoCam1 = load(strcat('cmf_',NameCam1,'.mat'));
        infoCam2 = load(strcat('cmf_',NameCam2,'.mat'));
        CSSCam1 = infoCam1.rgb(1:31,:);
        CSSCam2 = infoCam2.rgb(1:31,:);
        clear infoCam1 infoCam2
        
        LisName(NoComb,1) = {NameCam1};
        LisName(NoComb,2) = {NameCam2};
        % cal_VoraValue.m for Vora Value between main and telephoto cameras
        LisVora(NoComb,:) = cal_VoraValue(CSSCam1,CSSCam2);
        
        % calculate raw-response for all illuminantions
        WPsCam1 = zeros(size(SPDLab,2),size(CSSCam1,2));
        WPsCam2 = zeros(size(SPDLab,2),size(CSSCam2,2));
    
        for j = 1:size(SPDLab,2)
            WPsCam1(j,:) = SPDLab(:,j)'*CSSCam1;
            WPsCam2(j,:) = SPDLab(:,j)'*CSSCam2;
        end
        
        % normalize [R/G,1,B/G]
        WPsCam1Norm = WPsCam1./WPsCam1(:,2);
        WPsCam2Norm = WPsCam2./WPsCam2(:,2);
        
        %{
        figure;
        scatter(WPsCam1Norm(:,1),WPsCam1Norm(:,3));
        hold on
        scatter(WPsCam2Norm(:,1),WPsCam2Norm(:,3));
        %}
        
        MsWP1to2 = zeros(size(CSSCam1,2),size(CSSCam2,2),size(SPDLab,2));
        
        for j = 1:size(SPDLab,2)
            % [R G B]*M = [R G B]
            MsWP1to2(:,:,j) = pinv(WPsCam1Norm(j,:))*WPsCam2Norm(j,:);
        end
        
        % the First step in paper for every multi-camera system
        inputsLib = WPsCam1Norm(:,[1 3]);
        inoutpairs = zeros(size(MsWP1to2,1),size(MsWP1to2,2));
        for m = 1:size(MsWP1to2,1)
            for n = 1:size(MsWP1to2,2)
                output = squeeze(MsWP1to2(m,n,:));
                indexTemp = det_Input(inputsLib,output);
                inoutpairs(m,n) = indexTemp;
                clear indexTemp
            end
        end
        
        % save the results of first step
        LisInputInter(:,:,NoComb) = inoutpairs;
    
        indexShow = unique(inoutpairs);
        IllumsSelected = zeros(numInterval,2); % 2 means r_{W1} & b_{W1}
        for i = 1:size(indexShow,1)
            indexTemp = indexShow(i);
            [rowTemp,colTemp]=find(inoutpairs==indexTemp);
            outputsTemp = zeros(size(MsWP1to2,3),size(rowTemp,1));
            inputTemp = WPsCam1Norm(:,indexTemp);
            for j = 1:size(rowTemp,1)
                outputsTemp(:,j) = squeeze(MsWP1to2(rowTemp(j),colTemp(j),:));
            end
            %{
            the difference of det_interpolation.m and find_indices.m
            return is differet
            find_indice: return the index of selected illuminant
            det_interpolation: return the raw-response of selected illuminant
            %}
            IllumsSelected(:,i) = find_indices(inputTemp, outputsTemp, numInterval);
            %{
            explain the variable IllumsSelected
            for instance
            row 1st col 1st
            percentile0%~10% using r_{W1}, SPD with highest frequency
            row 2st col 2st
            percentile10%~20% using b_{W1}, SPD with highest frequency
            %}
        end
        
        % record the variable IllumsSelected in all loops
        ArrayIllum(:,:,NoComb) = IllumsSelected; 
        
        fprintf('%d/%d ends.\n',NoComb,size(combCam2,1));
    end
    
    tableSave = table(LisName,LisVora, ...
        'VariableNames',{'CamName', 'VoraValue'});
    save('./data/Results.mat', ...
        'tableSave','LisInputInter', ...
        'ArrayIllum','SPDLab');

end

%% summarize the results in loop
clear all
% all data obtained in loop
data = load('./data/Results.mat');
ArrayIllum = data.ArrayIllum;
SPDLab = data.SPDLab;
tableSave = data.tableSave;
LisInputInter = data.LisInputInter;
clear data

IllumFreq = zeros(size(ArrayIllum,1),size(ArrayIllum,2));
%{
for every group based on percentile and r_{W1} or b_{W1}
select one SPD with highest frequency
%}
for i = 1:size(ArrayIllum,1) % numIntervation
    for j = 1:size(ArrayIllum,2) % every input (R/G, B/G)
        ArrayIllumTemp = ArrayIllum(i,j,:); 
        ArrayIllumTemp = ArrayIllumTemp(:);
        [unique_elements, ~, idx] = unique(ArrayIllumTemp);
        element_counts = accumarray(idx, 1);
        [~, idxMax] = max(element_counts);
        IllumFreq(i,j) = unique_elements(idxMax);
    end
end

figure;
plot([400:10:700],SPDLab(:,IllumFreq(:)));
xlabel('Wavelength (nm)');
ylabel('Relative Power');
title('the chosen SPDs for white point alignment');