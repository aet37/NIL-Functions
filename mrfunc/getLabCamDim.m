function y=getLabCamDim(cam,micr,obj,mag)
% Usage ... y=getLabCamDim(cam,micr,obj,mag)
%
% Get lab image pixel dimensions given an objective and setup
% pix_dim is in micrometers and calibrated using a standard grid

if strcmp(cam,'Photometrics'),
  if strcmp(micr,'MVX-10'),
    if strcmp(obj,'1x'),
      % assumes typical configuration with tube lens and TV lens
      pixdim=[4000/374 4000/374];
    end;
  end;
elseif strcmp(cam,'SonyCCD'),
  if strcmp(micr,'MVX-10'),
    if strcmp(obj,'1x'),
      pixdim=[];
    end;
  end;
elseif strcmp(cam,'TeleCCD'),

elseif strcmp(cam,'2photon'),
  if strcmp(micr,'Prairie'),
    if strcmp(obj,'10x'),
      pixdim=[1133/512 1133/512];
    elseif strcmp(obj,'16x'),
      pixdim=[812/512 812/512];
    end;
  end;
end;

y=pixdim;

ys.camera=cam;
ys.microscope=micr;
ys.objective=obj;
ys.mag=mag;
ys.pix_dim=pixdim;
ys.pix_area=prod(pixdim);

