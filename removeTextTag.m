function xmlStruct = removeTextTag(xmlStruct)

if isstruct(xmlStruct)
    
    fieldN1 = fieldnames(xmlStruct);
    for iField1 = 1:length(fieldN1)
        
        if isstruct(xmlStruct.(fieldN1{iField1})) && isfield(xmlStruct.(fieldN1{iField1}), 'Text')
            xmlStruct.(fieldN1{iField1}) = xmlStruct.(fieldN1{iField1}).Text;
        else
            xmlStruct.(fieldN1{iField1}) = removeTextTag(xmlStruct.(fieldN1{iField1}));
        end
        
    end
elseif iscell(xmlStruct)
    
    for iCell = 1:length(xmlStruct)
        xmlStruct{iCell} = removeTextTag(xmlStruct{iCell});
    end
    
end
    