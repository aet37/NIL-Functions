function mynotify(str)
% Usage ... mynotify(str)

disp(str);
eval(sprintf('!terminal-notifier -title "bg_matlab" -message "%s"',str));

