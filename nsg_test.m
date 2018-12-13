function nsg_test(joblocation)

nsg_info;

[~, filename, ext] = fileparts(joblocation);
if isempty(ext)
    zipFile = fullfile(outputfolder, [ filename '.zip' ]);
    zip(zipFile, joblocation);
    nsg_test(zipFile);
else
    if ~strcmpi(ext, '.zip')
        error('Not a zip file');
    else
        tmpFolder = fullfile(outputfolder, [ filename num2str(rand(1)*1000000) ]);
        currentFolder = pwd;
        mkdir(tmpFolder);
        cd(tmpFolder);
        unzip(joblocation);
        
        cd(tmpFolder);
        testIfTestPresent = dir('test.m');
        if isempty(testIfTestPresent)
            zipContent = dir(pwd);
            for iZip = 1:length(zipContent)
                if isdir(zipContent(iZip).name) && zipContent(iZip).name(1) ~= '.' && zipContent(iZip).name(1) ~= '_'
                    cd(zipContent(iZip).name);
                    break;
                end
            end
        end
        disp('****************');
        disp('NOW RUNNING TEST');
        disp('****************');
        try
            test
        catch
            cd(currentFolder);
            error(lasterror);
        end
        disp('***************');
        disp('TEST SUCCESSFUL');
        disp('***************');
        rmdir(tmpFolder, 's');
        cd(currentFolder);
        
    end
end
