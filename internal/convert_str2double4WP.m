function numbers = convert_str2double4WP(strWP)

% strWP = DataDC1x.DaylightMultipliers;
% strWP = DataET1x.IFD0_AsShotNeutral;
% e.g. '2.508704 0.999959 1.674058'

numCell = regexp(strWP, '[\d\.]+', 'Match');
% numCell = regexp(strWP, '\d*\.\d*', 'Match');  % Extract all numbers as cell array of strings
numbers = str2double(numCell);  % Convert the cell array of strings to an array of doubles
numbers = numbers(1:3);

end