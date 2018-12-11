% call without arguments to get the list of jobs

function res2 = nsg_jobs(jobname, filetype)

nsg_info;
if nargin < 2
    filetype = 'xml';
end
if nargin < 1
    command = sprintf('curl -u arnodelorme:%s -H cipres-appkey:%s %s/job/arnodelorme > tmptxt.xml', nsgPASSWORD, nsgKEY, nsgURL);
    system(command);
    res2 = xml2struct('tmptxt.xml');
    res2 = removeTextTag(res2);    
else
    
    if strcmpi(filetype, 'xml')
        command = sprintf(['curl -u arnodelorme:%s -H cipres-appkey:%s %s > tmptxt.' filetype], nsgPASSWORD, nsgKEY, jobname);
        system(command);
        
        res2 = xml2struct('tmptxt.xml');
        res2 = removeTextTag(res2);
        
    elseif strcmpi(filetype, 'txt')
        command = sprintf(['curl -u arnodelorme:%s -H cipres-appkey:%s %s > tmptxt.' filetype], nsgPASSWORD, nsgKEY, jobname);
        system(command);
        res2 = [ 'tmptxt.' filetype ];
    else
        tmpval = fileparts(jobname);
        tmpval = fileparts(tmpval);
        [tmp foldname] = fileparts(tmpval);
        
        tmpFolder = fullfile(outputFolder, foldname);
        currentFolder = pwd;
        mkdir(tmpFolder)
        cd(tmpFolder);
        command = sprintf(['curl -u arnodelorme:%s -H cipres-appkey:%s %s > tmptxt.' filetype], nsgPASSWORD, nsgKEY, jobname);
        system(command);
        tmp = dir([ 'tmptxt.' filetype ]);
        if tmp.bytes == 0
            res2 = 0;
        else
            system( [ 'tar zxvf tmptxt.' filetype] );
            res2 = 1;
        end
        cd(currentFolder);
    end
end    
