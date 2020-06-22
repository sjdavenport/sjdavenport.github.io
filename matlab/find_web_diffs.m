global davenpor
webdir = [davenpor, 'Private_Projects/sjdavenport.github.io/'];

fid_dep = fopen([matdir,'talks_header.txt'],'r');
fid_new = fopen([matdir,'talks_header.txt'],'r');

header_data = textscan(fid_header, '%s', 'Delimiter','\n');

