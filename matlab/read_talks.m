global davenpor
webdir = [davenpor, 'Private_Projects/sjdavenport.github.io/matlab/'];
fileID = fopen([webdir,'talks_temp.html'],'r');
read_html_file = textscan(fileID, '%s', 'Delimiter','\n');

%%
title = ['title1';'title2'];
slides = [1,0]'
testtable = table(title,slides)

writetable(testtable, 'testtable.txt')

%%
header = 'title, date, time, uni, country, slides, code, toolbox, preprint, paperlink';
data = ['title', 'date', 'time', 'uni', 'country', 'slides', 'code', 'toolbox', 'preprint', 'paperlink'];

%% test writing
table = readtable('./talkdata.xlsx')
writetable(table, './testwrite.xlsx')

%%
table = readtable('./testwrite.xlsx')
