function vals = getACQP( ppName, ppPath )
% Usage ... vals = getACQP( ppName, ppPath)
%
% Get the values for parameter name in bruker ACQP file path

if nargin<2, ppPath=[]; end;

timeName='this string will not match anything';
if strcmp(ppName,'time_stamp')
    ind=strfind(ppPath,'\'); ind=ind(3);
    timeName=['$$ ',ppPath(ind+3:ind+6),'-',ppPath(ind+7:ind+8),'-',ppPath(ind+9:ind+10)];
end

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
            if strcmp(name, '##$NR')
                vals=str2num(line(length(name)+2:end));            
            elseif strcmp(name, '##$NECHOES')
                vals=str2num(line(length(name)+2:end));
            elseif strcmp(name, '##$ACQ_patient_pos')
                vals=line(length(name)+2:end);
            elseif strcmp(name, '##$PULPROG')
%                 vals=line(length(name)+2:end);
                vals = fgetl(fp);
            elseif strcmp(name, '##$NSLICES')
                vals=str2num(line(length(name)+2:end));
            elseif strcmp(name, '##$ACQ_flip_angle')
                vals=str2num(line(length(name)+2:end));
            elseif strcmp(name, '##$ACQ_slice_thick')
                vals=str2num(line(length(name)+2:end));
            elseif strcmp(name, '##$RG')
                vals=str2num(line(length(name)+2:end));
                
            elseif strcmp(name, '##$ACQ_obj_order')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$ACQ_size')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$ACQ_read_offset')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$ACQ_phase1_offset')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$ACQ_phase2_offset')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$ACQ_fov')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$ACQ_repetition_time')
                line = fgetl(fp);
                vals = str2num(line);
            elseif strcmp(name, '##$ACQ_echo_time')
                vals=[];
                for mm=1:1000
                    line = fgetl(fp);
                    temp=str2num(line);
                    if isempty(temp)
                        break;
                    else
                        vals = cat(2,vals,temp);
                    end
                end
            elseif strcmp(name, '##$ACQ_slice_offset')
                vals=[];
                for mm=1:1000
                    line = fgetl(fp);
                    temp=str2num(line);
                    if isempty(temp)
                        break;
                    else
                        vals = cat(2,vals,temp);
                    end
                end            
            end
            
        elseif strcmp(name, timeName)
                vals=line(4:26);
                
            break;
            
        end
    end
end

fclose( fp );
