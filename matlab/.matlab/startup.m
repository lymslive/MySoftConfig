% startup.m: called by %MATLABROOT/toolbox/local/matlabrc.m in searth path

startdir = '~/.matlab';
cd(startdir);

% get time and transform to yyyymmdd
ct=now;
yy=datestr(ct, 10);
md=datestr(ct,6);
md=regexprep(md,'/','');
ymd=[yy md];
ti=datestr(ct,13);

% record log with filename based on date
logName=[cd '\log\matlab' ymd '.log'];
diary(logName);
disp(['% Now is£º' datestr(now) 'MATLAB work BEGIN...']);
clear;

% load last workspace saveed in recent.mat, and cd to last work directory
load recent;
try
	cd (lastpath);
catch
	;
end
clear lastpath;

% additional path
addpath('/home/lymslive/.matlab/toolbox/xml');
addpath('/home/lymslive/.matlab/toolbox/gvaluer');
addpath('/home/lymslive/.matlab/toolbox/utility');
% addpath('/home/lymslive/.matlab/toolbox/xml/xml_io_tools');
addpath('/home/lymslive/longgu/matlab');
% addpath('/home/lymslive/longgu/matlab/tools');
