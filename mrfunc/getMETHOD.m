function vals = getMETHOD( ppName, ppPath )
% Usage ... vals = getMETHOD( ppName, ppPath )
%
% Get the values for parameter name in bruker ACQP file path

ppName=strcat('##$',ppName);

fp = fopen( ppPath, 'r');
done = 0;
vals = [];

while( done == 0 )
    line = fgetl(fp);
    if (line == -1)
        done = 1;
    elseif ~isletter(line)
    elseif length(line)<length(ppName)
    else
        
        name=line(1:length(ppName));
        
        if strcmp(name, ppName)
            if strcmp(name, '##$NSegments')
                vals=str2num(line(length(name)+2:end));
            elseif strcmp(name, '##$PVM_EncTotalAccel')
                vals=str2num(line(length(name)+2:end));
            elseif strcmp(name, '##$Red_Factor')
                vals=str2num(line(length(name)+2:end));
            elseif strcmp(name, '##$PVM_EpiMatrix')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$PVM_Matrix')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$PVM_SPackArrSliceOrient')
                vals = fgetl(fp);
            elseif strcmp(name, '##$PVM_SPackArrReadOrient')
                vals = fgetl(fp);
            elseif strcmp(name, '##$Sli_val') || strcmp(name, '##$Gradp2') || strcmp(name, '##$TSL')
                vals=[];
                for mm=1:10000
                    line = fgetl(fp);
                    temp=str2num(line);
                    if isempty(temp)
                        break;
                    else
                        vals = cat(2,vals,temp);
                    end
                end
            
            end
            break;
            
        end
    end
end

fclose( fp );
