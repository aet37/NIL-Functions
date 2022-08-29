function ms=mkMexStruct1(id,dob,fnames)
% Usage ... ms=mkMexStruct1(id,dob,fnames)
%
% Makes the MexImage Structure for a given mouse for all images in fnames
% provided

do_edit=0;
if isempty(id),
  id=input('  mouseID= ','s');
elseif isstruct(id),
  do_edit=1;
end;

if do_edit,
  ms=id;
  for mm=1:length(ms),
      tmpcnt1=0; tmpims=[];
      if length(ms(mm).img_all)<30,
          % there are multiple images here
          for nn=1:length(ms(mm).img_all),
              if length(ms(mm).img_all{nn})<30,
                  % there are multiple images here also
                  for oo=1:length(ms(mm).img_all{nn}), 
                      tmpcnt1=tmpcnt1+1;
                      tmpims{tmpcnt1}=ms(mm).img_all{nn}{oo};
                  end;
              else,
                  tmpcnt1=tmpcnt1+1;
                  tmpims{tmpcnt1}=ms(mm).img_all{nn};
              end;
          end;
          %size(tmpims),
          figure(1), clf, showmany(tmpims), drawnow,
          tmpin1=input('  select image #: ');
          if isempty(tmpin1), tmpin1=1; end;
          ms(mm).ii=[tmpin1];
          ms(mm).fname=ms(mm).fname_all{nn};
          ms(mm).img=tmpims{tmpin1};
          ms(mm).mag=ms(mm).mag_all(1);
          disp(sprintf('  #%d: %d  %s',mm,tmpin1,ms(mm).imgDate));
      else,
          % there is only one iamge
          tmpcnt1=tmpcnt1+1;
          tmpims{tmpcnt1}=ms(mm).img_all{nn};
          ms(mm).ii=[1];
          ms(mm).fname=ms(mm).fname_all{1};
          ms(mm).img=ms(mm).img_all{1};
          ms(mm).mag=ms(mm).mag_all(1);      
      end
      tmpok2=0;
      tmpminmax1=[min(ms(mm).img(:)) max(ms(mm).img(:))];
      tmpminmax=tmpminmax1;
      while(~tmpok2)
        figure(1), clf,
        show(ms(mm).img,tmpminmax)
        tmpin2=input(sprintf('  adjust min/max (%f/%f)? [enter=no, [v1 v2]]: ',tmpminmax(1),tmpminmax(2)),'s');
        if isempty(tmpin2),
          tmpok2=1; 
        else,
          eval(sprintf('tmpminmax=[%s];',tmpin2));
          if length(tmpminmax)==1, tmpminmax=tmpminmax1; end;
        end;
      end
      ms(mm).img=imwlevel(ms(mm).img,tmpminmax,0);
  end
  clear tmpcnt1 tmpims
else,

cnt1=0;
cnt2=0;
for mm=1:length(fnames),
  disp(sprintf('  %d: %s',mm,fnames{mm}));
  tmpin=input('  new entry? [0=no, 1/enter=yes]: ');
  if isempty(tmpin), tmpin=1; end;
  if tmpin==1,
    cnt1=cnt1+1;
    cnt2=1;
    ms(cnt1).mouseID=id;
    ms(cnt1).mouseDOB=dob;
    ms(cnt1).imgDate=[];
    ms(cnt1).fname=[];
    ms(cnt1).img=[];
    ms(cnt1).mag=[];
    ms(cnt1).ii=[];
    disp(sprintf('  [e#%d  d#%d]',cnt1,cnt2));
    if strcmp(fnames{mm}(end-2:end),'tif')|strcmp(fnames{mm}(end-2:end),'TIF')|strcmp(fnames{mm}(end-2:end),'stk'),
        tmpinfo=imfinfo(fnames{mm});
        tmpnims=length(tmpinfo);
        if isfield(tmpinfo(1),'FileModDate'),
            tmpdate1=tmpinfo(1).FileModDate;
            disp(sprintf('  found #im=%d and date= %s',tmpnims,tmpdate1));
        else,
            tmpdate1=[];
        end;
    else,
        tmpinfo=[];
        tmpinfo.valid=0;
        tmpnims=1;
    end;
    tmpdate=input('  enter imgDate= ','s');
    if isempty(tmpdate), tmpdate=tmpdate1; end;
    ms(cnt1).imgDate=tmpdate;
    ms(cnt1).fname_all{cnt2}=fnames{mm};
    if tmpnims==1,
      ms(cnt1).img_all{cnt2}=readOIS3(fnames{mm});
    else,
      for nn=1:tmpnims, ms(cnt1).img_all{cnt2}{nn}=readOIS3(fnames{mm},nn); end;
    end;
    disp('  displaying images...');
    figure(1), clf, showmany(ms(cnt1).img_all{cnt2}), drawnow,
    tmpmag=input('  enter mag= ');
    ms(cnt1).mag_all(cnt2)=tmpmag;
    tmpdim=input('  enter pixDim [pm=6.6, cam=13.4, pco= 4]: ');
    ms(cnt1).pixDim=tmpdim;
  else,
    if cnt1==0, cnt1=1; end;
    cnt2=cnt2+1;
    disp(sprintf('  [e#%d  d#%d]',cnt1,cnt2));
    ms(cnt1).fname_all{cnt2}=fnames{mm};
    ms(cnt1).img_all{cnt2}=readOIS3(fnames{mm});
    disp('  displaying images...');
    figure(1), clf, showmany(ms(cnt1).img_all{cnt2}), drawnow,
    tmpmag=input('  enter mag= ');
    ms(cnt1).mag_all(cnt2)=tmpmag;
  end;
  ms(cnt1).mask=[];
  ms(cnt1).maskSum=[];
  ms(cnt1).ageNum=datenum(tmpdate)-datenum(dob);
end;
end;
