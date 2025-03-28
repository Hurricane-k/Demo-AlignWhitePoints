function index = det_Input(inputsLib,output)

% aims of this function
% I plan to use log(R/G) or log(B/G) to do local mapping
% when return 1, R/G is better to predict certain element in mapping
% when return 3, B/G is better to predict certain element in mapping

LisMAE = zeros(size(inputsLib,2),1);
for i = 1:size(inputsLib,2)
    inputTemp = log(inputsLib(:,i));
    modelTemp = fitrgp(inputTemp,output);
    outputPred = predict(modelTemp,inputTemp);
    
    %{
    figure;
    scatter(inputTemp,output);
    hold on;
    scatter(inputTemp,outputPred,'.');
    %}
       
    % abbr MAE: mean absolute value
    MAETemp = mean(abs(outputPred-output));
    LisMAE(i,:) = MAETemp;
    clear MAETemp modelTemp outputPred inputTemp
end

[valule, index]=min(LisMAE);

if index > 1
    index = index+1;
end


end