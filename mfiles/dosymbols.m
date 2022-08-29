dlha = get(gca,'children');
dlln = length(dlha);
for dllp = dlln:-1:1,
 if rem(dlln-dllp,4) == 0 
  set(dlha(dllp),'LineStyle','*');
 end
 if rem(dlln-dllp,4) == 1 
  set(dlha(dllp),'LineStyle','o');
 end
 if rem(dlln-dllp,4) == 2 
  set(dlha(dllp),'LineStyle','+');
 end
 if rem(dlln-dllp,4) == 3 
  set(dlha(dllp),'LineStyle','x');
 end
end

clear dlha dlln dllp

