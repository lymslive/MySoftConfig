startup.m, startup folder, userpath 的关系笔记

核心摘要：
1. 在~/.matlab中建立startup.m, finish.m脚本及log目录
2. 在~/.profile中设置环境变量MATLAB_USE_USERPATH=1
3. 初次运行MATLAB后，用命令 userpath('/home/lymslive/.matlab') 设置启动目录
4. .matlab 目录中的 pathdef.m 无效，须在startup.m文件中用addpath加入其他需要的
  搜索路径，但不包括.matlab本身，因为userpath已经加入了。

startup.m 须要在MATLAB的搜索路径中，~/.matlab却默认不在搜索路径中。在ubuntu中
，matlab一般安装在/usr/local/MATLAB/R20**a中。所以在初次启动MATLAB在对话框中将
~/.matlab加入path，是无法保存pathdef.m的，除非用sudo启动。

MALAB在unix中启动目录（startup folder），按帮助是说在~/Documents/MATLAB中，但
我初次启动MATLAB输入userpath查看时，却是空，未设置。

用 userpath('/home/lymslive/.matlab') 设置用户目录能永久生效，不存在类似
pathdef.m 写权限问题（莫非该信息保存在~/.matlab/R20**a/目录下）。

须设置环境变量 MATLAB_USE_USERPATH=1 （如在~/.profile中），才能使下次在任意目
录中启动MATLAB时将userpath作为启动目录。

但保存在 ~/.matlab 目录中的pathdef.m竟然不生效，只将 ~/.matlab 本身加入path顶
端。可能是由于matlabrc.m处理pathdef.m比startup.m早吧。比较靠谱的方法是在
startup.m 中添加其他其他需要的 path.

按帮助 userpath('reset') 将重置用户目录为 ~/Documents/MALAB ，但由于中文版
Ubuntu默认建立的是“文档”而非“Document”，故无法重置。个人喜欢用 .matlab ，那就
这样吧。
