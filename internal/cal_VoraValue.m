function voraValue = cal_VoraValue(QE1,QE2)

%% Disclaimer
% Reference 1: Poorvi L. Vora and H. Joel Trussell. 
% Measure of goodness of a set of color scanning filters. 
% Journal of the Optical Society of America-A, vol. 10, no. 7, pp. 1499-1508, July 1993.

% Reference 2: Yuteng-ZHU, PhD thesis

%% body of func
alpha = 3; % in this case, alpha = 3

voraValue = trace(QE1*pinv(QE1)*QE2*pinv(QE2)) / alpha;


end