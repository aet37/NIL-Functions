function out = wtslcseq(filename,fileroot,noslices,updateloc)
%
% Usage ... wtslcseq(filename,fileroot,noslices,updateloc);
% 
% Writes a file with the slice sequence to read
% with the first file named fileroot (.n) and the
% last file fileroot (.n+noslices). The parameter 
% updateloc indicates the position in the string
% to commence modifying.
%
% NOTE: Function assumes the file extension for the
%	slice follows the following format:
%		<fileroot>.000
%	where 000 is n
%       Also, the noslices must have 3 characters and
%       enclosed in quotes!
%
% Example: wtslcseq('sl1seq.txt','sl1.001','144',7);
%

ii = 0;
fid = fopen(filename,'wb');
if (fid ~= 2),
  fwrite(fid,noslices,'char*1');
  fwrite(fid,fileroot,'char*1');
  while ( ii < str2num(noslices)-1 ),
    if ( abs(fileroot(updateloc)) < 57 ),
      fileroot(updateloc) = fileroot(updateloc) + 1;
      fileroot = setstr(fileroot);
    elseif ( abs(fileroot(updateloc)) == 57),
      fileroot(updateloc) = 48;
      fileroot(updateloc-1) = fileroot(updateloc-1) + 1;
      if ( abs(fileroot(updateloc-1)) == 58 ),
        fileroot(updateloc-1) = 48;
        fileroot(updateloc-2) = fileroot(updateloc-2) + 1;
      end;
      fileroot = setstr(fileroot);
    end;
    fwrite(fid,fileroot,'char*1');
    ii = ii + 1;
  end;
end;

out = fid;
fclose(fid);
