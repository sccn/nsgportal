function nsg_run(joblocation)

nsg_info;

[~, filename, ext] = fileparts(joblocation);
if isempty(ext)
    zipFile = fullfile(outputfolder, [ filename '.zip' ]);
    zip(zipFile, joblocation);
else
    zipFile = joblocation;
end

% submit job
command = sprintf('curl -u arnodelorme:%s -H cipres-appkey:%s %s/job/arnodelorme -F tool=EEGLAB_TG -F input.infile_=@%s -F metadata.statusEmail=true > tmptxt.xml', nsgpassword, nsgkey, nsgurl, zipFile);
system(command);
disp('Job has been submitted!');