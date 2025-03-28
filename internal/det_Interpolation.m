function Interpolation = det_Interpolation(inputTemp,outputsTemp, numInterval)

% how to set interpolation for input and output

% inputTemp
% outputsTemp

nodes= linspace(0,100,numInterval+1);
Interpolation = zeros(size(nodes,2)-1,size(inputTemp,2)+size(outputsTemp,2));

for i = 1:size(nodes,2)-1
    boundLower = prctile(log(inputTemp),nodes(i));
    boundUpper = prctile(log(inputTemp),nodes(i+1));
    indices = find(log(inputTemp)>=boundLower & log(inputTemp)<=boundUpper);
    inputTempln = log(inputTemp);
    inputPartln = inputTempln(indices,:);
    outputsPart = outputsTemp(indices,:);
    inoutsPart = [inputPartln outputsPart];
    [~,indexMin]=min(sum(power(inoutsPart-mean(inoutsPart),2),2));
    Interpolation(i,:) = inoutsPart(indexMin,:);
end

%{
figure;
for k = 1:size(outputsTemp,2)
    scatter(log(inputTemp),outputsTemp(:,k),'.');
    hold on
    scatter(Interpolation(:,1),Interpolation(:,k+1),'s','filled');
    hold on
end
%}

end