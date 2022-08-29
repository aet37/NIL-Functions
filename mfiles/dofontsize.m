function a = dofontsize(sz)

tmph=gcf;

if length(tmph.Children)>1,
dlha = get(gca,'Title');
set(dlha(:),'FontSize',sz);
dlha = get(gca,'XLabel');
set(dlha(:),'FontSize',sz);
dlha = get(gca,'YLabel');
set(dlha(:),'FontSize',sz);
dlha = get(gca,'ZLabel');
%set(dlha(:),'FontSize',sz);
%dlha = get(gca,'ZTickLabels');
set(dlha(:),'FontSize',sz);
    
else,
dlha = get(gca,'Title');
set(dlha(:),'FontSize',sz);
dlha = get(gca,'XLabel');
set(dlha(:),'FontSize',sz);
dlha = get(gca,'YLabel');
set(dlha(:),'FontSize',sz);
dlha = get(gca,'ZLabel');
%set(dlha(:),'FontSize',sz);
%dlha = get(gca,'ZTickLabels');
set(dlha(:),'FontSize',sz);
end

a = sz;
