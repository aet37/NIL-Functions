function rmsk=manyRadROIs2(im,seg1,parms,auto_flag_override)
% Usage ... rmsk=manyRadROIs(im,segStruc,parms,auto_flag_override)
%
% parms=[wfr pord ny dxy wstp inv_flag];
% for ex., parms=[0.5 2 4 0.2 4 1];


%load ~/Data/2photon/kazu/tmpres2
%load ~/Data/2photon/kazu/masks2


wfr=parms(1);
pord=parms(2);
ny=parms(3);
dxy=parms(4);
wstp=parms(5);
inv_flag=parms(6);

if isempty(seg1),
  segCl=ones(size(im));
  auto_flag=0;
else,
  segCl=seg1.segCl;
  segIm=seg1.segIm;
  treeIm=seg1.treeIm;
  segIm=seg1.im;
  nseg=max(max(segIm));
  auto_flag=1;
end;
% slit_wid npix pix_int

if nargin==4,
  auto_flag=auto_flag_override;
end;

max_val=4096;
tmppord=2;


if auto_flag==1,
  for mm=1:nseg,
    % determines: ww, pp, row_flag, ij_start, ij_end
    % first determine the width of the rad slit
    tmpim=bwdist(segIm==mm);
    ww(mm)=round(wfr*max(max(im)));
    % second, determine start and finish
    [tmpi,tmpj]=find(treeIm.*(segIm==mm));
    % determine start point
    if (max(tmpi)-min(tmpi))>(max(tmpj)-min(tmpj)),
      pp{mm}=polyfit(tmpi,tmpj,pord);
      row_flag(mm)=1;
      ij_ends{mm}=[min(tmpi) polyval(pp{mm},min(tmpi));
               max(tmpi) polyval(pp{mm},max(tmpi))];
      %check if in the image
    else,
      pp{mm}=polyfit(tmpj,tmpi,pord);
      row_flag(mm)=0;
      ij_ends{mm}=[polyval(pp{mm},min(tmpj)) min(tmpj);
               polyval(pp{mm},max(tmpj)) max(tmpj)];
      %check if in the image
    end;
    % show locations of end points and estimated widths
    for nn=1:size(ij_ends{mm},1),
      if row_flag(mm),
        tmp=mypolyvecs(pp{mm},ij_ends{mm}(nn,1));
        p1{mm}(nn,:)=ij_ends{mm}(nn,:)+0.5*ww(mm)*tmp.pv;
        p2{mm}(nn,:)=ij_ends{mm}(nn,:)-0.5*ww(mm)*tmp.pv;
        %check if in the image
      else,
        tmp=mypolyvecs(pp{mm},ij_ends{mm}(nn,2));
        p1{mm}(nn,:)=ij_ends{mm}(nn,:)+0.5*ww*tmp.pv;
        p2{mm}(nn,:)=ij_ends{mm}(nn,:)-0.5*ww*tmp.pv;
        %check if in the image
      end;
    end;
    p1{mm}=round(p1{mm});
    p2{mm}=round(p2{mm});
    ij_ends{mm}=round(ij_ends{mm});
    msk{mm}=imdilate(pixtoim([p1{mm}(:,2) p1{mm}(:,1);p2{mm}(:,2) p2{mm}(:,1);ij_ends{mm}(:,2) ij_ends{mm}(:,1)],size(im)),ones(3,3));
    show(im_super(im,msk{mm}+(segIm==mm),0.3)), drawnow, 
    disp(sprintf('  press enter to continue (%d)...',mm));
    pause;
  end;
else,
  mm=1;
  good_loc0=0;
  while(~good_loc0),
    % select ww, ij_ends interactively
    good_loc=0;
    while(~good_loc),
      disp(sprintf('  select end-points along the vessel (sequential, 2+ ok), press enter when done...'));
      %show(im_super(im,segCl==mm,0.3)), drawnow,
      figure(1),
      show(im), drawnow,
      ii=round(ginput);
      tmpmsk=imdilate(pixtoim([ii(:,2) ii(:,1)],size(im)),ones(3,3));
      show(im_super(im,tmpmsk,2.0)), drawnow,
      good_loc=input('  selection ok? [1=yes, 0=no]: ');
    end;
    ij_ends{mm}=ii;
    msk{mm}=tmpmsk;
    for nn=1:size(ij_ends{mm},1)-1,
      ij_dist{mm}(nn)=sqrt((ij_ends{mm}(nn+1,1)-ij_ends{mm}(nn,1))^2+(ij_ends{mm}(nn+1,2)-ij_ends{mm}(nn,2))^2);
    end;
    good_loc=0;
    while(~good_loc),
      disp(sprintf('  select slit pts (2) for each end-point in order ...'));
      show(im_super(im,msk{mm},2.0)), drawnow,
      ii=round(ginput(2*size(ij_ends{mm},1)));
      tmpmsk=imdilate(pixtoim([ii(:,2) ii(:,1)],size(im)),ones(3,3));
      show(im_super(im,tmpmsk,2.0)), drawnow,
      good_loc=input('  selection ok? [1=yes, 0=no]: ');
    end;
    for nn=1:size(ij_ends{mm},1),
      ij_ww{mm}(nn)=round(sqrt(((ii(2*nn-1,1)-ii(2*nn,1))^2)+((ii(2*nn-1,2)-ii(2*nn,2))^2)));
    end;
    ww(mm)=mean(ij_ww{mm});
    cnt=1;
    for nn=1:size(ij_ends{mm},1)-1,
      tmpvec=[ij_ends{mm}(nn+1,1)-ij_ends{mm}(nn,1) ij_ends{mm}(nn+1,2)-ij_ends{mm}(nn,2)];
      tmpvec=tmpvec/sqrt(sum(tmpvec.^2));
      tmpvec=tmpvec*wstp;
      good_loc=0; cnt2=0;
      while(~good_loc),
        % get preliminary slit position
        cnt2=cnt2+1;
        tmpaloc=ij_ends{mm}(nn,:)+tmpvec*cnt2;
        tmpaloc=[tmpaloc(2) tmpaloc(1)];
        tmpww=ij_ww{mm}(nn)+(ij_ww{mm}(nn+1)-ij_ww{mm}(nn))*cnt2*wstp/ij_dist{mm}(nn);
        tmpang=atan(tmpvec(2)/tmpvec(1))*(180/pi);
        tmpang=tmpang+90;
        if auto_flag==2,
          tmpangr=tmpang+[-10:2:10];
          for oo=1:length(tmpangr),
            [tmp1r,tmpmsk1r]=getRectImGrid(im,[ny tmpww],dxy,tmpaloc,tmpangr(oo)); 
            tmpyyr(:,oo)=mean(tmp1r,2)';
            if inv_flag, tmpyyr(:,oo)=max_val-tmpyyr(:,oo); end;
            tmpradr(oo,:)=calcRadius3b(tmpyyr(:,oo)');
          end;
          tmpfitr=polyfit(tmpangr,tmpradr(:,1)',tmppord);
          tmpfitv=polyval(tmpfitr,tmpangr);
          tmpfiti=find(tmpfitv==min(tmpfitv));
          disp(sprintf('    selecting %d: %.2f (%.2f)',cnt2,tmpang,tmpangr(tmpfiti)));
          if (~isempty(tmpfiti))|(tmpfitr(1)>=0), tmpang=tmpangr(tmpfiti); end;
          clear tmpyyr tmpradr
        end;
        [tmp1,tmpmsk1]=getRectImGrid(im,[ny tmpww],dxy,tmpaloc,tmpang); 
        tmpyy=mean(tmp1,2)';
        show(im_super(im,tmpmsk1,0.3)), drawnow,
        tmprmsk.rw=[ny tmpww];
        tmprmsk.dxy=dxy;
        tmprmsk.aloc=tmpaloc;
        tmprmsk.ang=tmpang;
        tmprmsk.yp=tmpyy;
        tmp_rmsk{cnt2}=tmprmsk;
        % check end, tmpsave
        if (ij_dist{mm}(nn)<(cnt2*wstp)),
          good_loc=1;
          %save tmp_manyRadROIs2
        end;
      end;
      if auto_flag==2, for oo=1:length(tmp_rmsk), tmpplang(oo)=tmp_rmsk{oo}.ang; end; figure(2), plot(tmpplang), end;
      % prompt for modification necessary?
      angsel1=input(sprintf('  [%d/%d/%d]:  Select? [1=all,2=modify]: ',nn,size(ij_ends{mm},1),cnt2));
      if angsel1==2,
        for oo=1:cnt2,
          [tmp1,tmpmsk1]=getRectImGrid(im,tmp_rmsk{oo}.rw,tmp_rmsk{oo}.dxy,tmp_rmsk{oo}.aloc,tmp_rmsk{oo}.ang); 
          tmpyy=mean(tmp1,2)';
          figure(1),
          show(im_super(im,tmpmsk1,0.3)), drawnow,
          angsel2=input(sprintf('    [%.1f,%.1f]:  angle= %.1f ,  select? [1=this_one,2=manual,3=optimize,4=eliminate]: ',wstp*cnt2,ij_dist{mm}(nn),tmpang));
          if angsel2==2,
            found2=0;
            while(~found2),
              ang3=input(sprintf('      enter angle: '));
              [tmp1,tmpmsk1]=getRectImGrid(im,tmp_rmsk{oo}.rw,tmp_rmsk{oo}.dxy,tmp_rmsk{oo}.aloc,ang3); 
              figure(1),
              show(im_super(im,tmpmsk1,0.3)), drawnow,
              angsel3=input(sprintf('      [1=yes, 0=no, 9=no&next]: '));
              if angsel3==1, found2=1; tmp_rmsk_yn(oo)=1; end;
              if angsel3==9, found2=1; tmp_rmsk_yn(oo)=0; end;
            end;
            tmp_rmsk{oo}.ang=ang3;
            tmp_rmsk_yn(oo)=1;
          elseif angsel2==3,
            % optimize here
            tmpang3=[-20:2:20]+tmp_rmsk{oo}.ang;
            for pp=1:length(tmpang3),
              [tmp1,tmpmsk1]=getRectImGrid(im,tmp_rmsk{oo}.rw,tmp_rmsk{oo}.dxy,tmp_rmsk{oo}.aloc,tmpang3(pp)); 
              tmpyy3(pp,:)=mean(tmp1,2)';
              if inv_flag, tmpyy3(pp,:)=max_val-tmpyy3(pp,:); end;
              tmprad3(pp,:)=calcRadius3b(tmpyy3(pp,:));
            end;
            tmppfit=polyfit(tmpang3,tmprad3(:,1)',tmppord);
            tmppval=polyval(tmppfit,tmpang3);
            tmpri=find(tmppval==min(tmppval));
            if ~isempty(tmpri), tmpang3new=tmpang3(tmpri); else, tmpang3new=tmp_rmsk{oo}.ang; end;
            [tmp1,tmpmsk1]=getRectImGrid(im,tmp_rmsk{oo}.rw,tmp_rmsk{oo}.dxy,tmp_rmsk{oo}.aloc,tmpang3new);
            figure(1),
            show(im_super(im,tmpmsk1,0.3)), drawnow,
            clear tmpyy3 
            angsel4=input(sprintf('    optimal angle= %.1f,   select? [1=yes,0=no,4=manual,9=no&exit]: ',tmpang3new));
            if angsel4==1,
              tmp_rmsk{oo}.ang=tmpang3new;
              tmp_rmsk_yn(oo)=1;
            elseif angsel4==4;
              found4=0;
              while(~found4),
                ang3=input(sprintf('      enter angle: '));
                [tmp1,tmpmsk1]=getRectImGrid(im,tmp_rmsk{oo}.rw,tmp_rmsk{oo}.dxy,tmp_rmsk{oo}.aloc,ang3);
                figure(1),
                show(im_super(im,tmpmsk1,0.3)), drawnow,
                angsel3=input(sprintf('      [1=yes, 0=no, 9=no&next]: '));
                if angsel3==1, found4=1; tmp_rmsk_yn(oo)=1; end;
                if angsel3==9, found4=1; tmp_rmsk_yn(oo)=0; end;
              end;
            elseif angsel4==9,
              tmp_rmsk_yn(oo)=0;
            else,
              tmp_rmsk_yn(oo)=1;
            end;
          elseif angsel2==4,
            tmp_rmsk_yn(oo)=0;
          else,
            tmp_rmsk_yn(oo)=1;
          end;
        end;
        cnt3=1; 
        for oo=1:cnt2,
          if tmp_rmsk_yn(oo),
             rmsk{mm}{cnt3+cnt-1}=tmp_rmsk{oo}; 
            cnt3=cnt3+1;
          end;
        end;
        disp(sprintf('    #ROIs= %d',cnt2));
        cnt=cnt+cnt3;
      else,
        for oo=1:cnt2,
          rmsk{mm}{oo+cnt-1}=tmp_rmsk{oo};
        end;
        disp(sprintf('    #ROIs= %d',cnt2));
        cnt=cnt+cnt2;
      end;
    end;
    clear tmp_rmsk
    tmpsel=input('  Another location? [1=Yes, 0=End]: ');
    if tmpsel==1,
      mm=mm+1;
    else,
      good_loc0=1;
    end;
  end;
end;


 
