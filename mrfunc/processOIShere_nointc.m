
%
% myOISscr1_new process of the data files in this folder
%

clear all
close all


cam_bin=[3 3 3];
cam_nims=9300;
pm_bin=[2 2 2];
pm_nims=6200;

tmp=dir('*.raw');
tmp2=dir('*.mat');

if ~isempty(tmp),
  for mm=1:length(tmp),
    % check file has not been processed by matlab
    tmp_skip=0;
    if ~isempty(tmp2),
      for nn=1:length(tmp2),
        load(tmp2(nn).name,'fname');
        if exist('fname','var'),
          for oo=1:length(tmp),
            if strcmp(tmp(oo).name,fname),
              tmp_skip=1;
            end;
          end;
        end;
      end;
    end;
    if ~tmp_skip,
      tmpre=regexp(tmp(mm).name,'_');
      tmpid=[tmp(mm).name(tmpre(1)+1:tmpre(2)-1),'_620_',tmp(mm).name(tmpre(end)+1:end-4)];
      if mm==1,
        disp(sprintf('  processing %02d: %s with id %s then loading',mm,tmp(mm).name,tmpid));
        myOISscr1_new(tmp(mm).name,tmpid,'do_load',[1:cam_nims],'do_crop','do_bin',cam_bin,'do_binfirst','do_motc');
        eval(sprintf('load %s_res crop_ii mask_reg',tmpid));
      else,
        disp(sprintf('  processing %02d: %s with id %s',mm,tmp(mm).name,tmpid));
        myOISscr1_new(tmp(mm).name,tmpid,'do_load',[1:cam_nims],'do_crop',crop_ii,'do_bin',cam_bin,'do_binfirst','do_motc');
      end;
    else,
      disp(sprintf('  skipping %02d: %s, mat file found',mm,tmp(mm).name));
    end;
  end;
else,
  disp('  no raw files found');
end;

tmp=dir('*.stk');
tmp2=dir('*.mat');

if ~isempty(tmp),
  for mm=1:length(tmp),
    % check file has not been processed by matlab
    tmp_skip=0;
    if ~isempty(tmp2),
      for nn=1:length(tmp2),
        load(tmp2(nn).name,'fname');
        if exist('fname','var'),
          for oo=1:length(tmp),
            if strcmp(tmp(oo).name,fname),
              tmp_skip=1;
            end;
          end;
        end;
      end;
    end;
    if ~tmp_skip,
      tmpre=regexp(tmp(mm).name,'_');
      tmpid=[tmp(mm).name(tmpre(1)+1:tmpre(2)-1),'_gcamp_',tmp(mm).name(tmpre(end)+1:end-4)];
      if mm==1,
        disp(sprintf('  processing %02d: %s with id %s then loading',mm,tmp(mm).name,tmpid));
        myOISscr1_new(tmp(mm).name,tmpid,'do_load',[1:pm_nims],'do_crop','do_bin',pm_bin,'do_binfirst','do_motc');
        eval(sprintf('load %s_res crop_ii mask_reg',tmpid));
      else,
        disp(sprintf('  processing %02d: %s with id %s',mm,tmp(mm).name,tmpid));
        myOISscr1_new(tmp(mm).name,tmpid,'do_load',[1:pm_nims],'do_crop',crop_ii,'do_bin',pm_bin,'do_binfirst','do_motc');
      end;
    else,
      disp(sprintf('  skipping %02d: %s, mat file found',mm,tmp(mm).name));
    end;
  end;
else,
  disp('  no stk files found');
end;

