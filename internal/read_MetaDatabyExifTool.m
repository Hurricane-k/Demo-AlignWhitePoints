function metadataStruct = read_MetaDatabyExifTool(imagePath,imageName,exifToolPath)

% Define the path to the ExifTool executable
% On Windows, it might be something like 'C:\path\to\exiftool.exe'
% On macOS or Linux, it might just be 'exiftool' if it's installed globally
% exifToolPath = 'E:\ExifTool\exiftool.exe'; % Update this to the path where ExifTool is installed

imageFull = strcat(imagePath,'/',imageName);

% Construct the command to read metadata using ExifTool
command = [exifToolPath, ' -j -a -u "', imageFull, '"'];

% Call ExifTool from MATLAB and capture the output
[status, result] = system(command);

% Check if the command was executed successfully
if status == 0
    % Parse the JSON output
    metadataStruct = jsondecode(result);
    
    % Display the metadata
    disp(metadataStruct);
else
    % Display an error message
    disp('Error executing ExifTool command');
end

end