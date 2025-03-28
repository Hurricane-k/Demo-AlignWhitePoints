function LisNoIllum = find_indices(inputTemp,outputsTemp, numInterval)

% it is inspired by the function 'det_Interpolation'
% but the return is the indices of the illuminant

% inputTemp
% outputsTemp

nodes= linspace(0,100,numInterval+1);
LisNoIllum = zeros(numInterval,1);

for i = 1:size(nodes,2)-1
    boundLower = prctile(log(inputTemp),nodes(i));
    boundUpper = prctile(log(inputTemp),nodes(i+1));
    indices = find(log(inputTemp)>=boundLower & log(inputTemp)<=boundUpper);
    %{
    for instance
    in 0%~10% percentile
    if m_{11}, m{12}, m_{13} using r_{W1} to select SPD, other elements
    using b_{W1}
    
    we find the nearest point to [mean(r_W1) mean(m_{11}) mean(m_{12}) mean(m_{13})]
    therefore we can reduce the quantity of SPDs to 20 at most
    %}
    inputTempln = log(inputTemp);
    inputPartln = inputTempln(indices,:);
    outputsPart = outputsTemp(indices,:);
    inoutsPart = [inputPartln outputsPart];
    [~,indexMin] = min(sum(power(inoutsPart-mean(inoutsPart),2),2));
    LisNoIllum(i,:) = indices(indexMin);
end


end