function vers = eegplugin_icansg(fig,  try_strings, catch_strings);
vers = '0.1';
plotmenu = findobj(fig, 'tag', 'tools');
submenu = uimenu( plotmenu, 'Label', 'Run ICA via NSG', 'separator', 'on', 'callback',...
    [try_strings.no_check '[EEG]=pop_icansg(EEG);' catch_strings.add_to_hist]);
