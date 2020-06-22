global davenpor
webdir = [davenpor, 'Private_Projects/sjdavenport.github.io/talks/'];

fid_dep = fopen([webdir,'index_dep.html'],'r');
fid_mine = fopen([webdir,'index_mine.html'],'r');

dep = textscan(fid_dep, '%s', 'Delimiter','\n');
dep = dep{1};
mine = textscan(fid_mine, '%s', 'Delimiter','\n');
mine = mine{1};

ndivs_dep = 0;
ndivs_closed_dep = 0;

ndivs_mine = 0;
ndivs_closed_mine = 0;

for I = 1:length(dep)
    ndivs_dep = ndivs_dep + length(strfind(dep{I}, '<div'));
    ndivs_closed_dep = ndivs_closed_dep + length(strfind(dep{I}, '/div'));
end

for I = 1:length(mine)
    ndivs_mine = ndivs_mine + length(strfind(mine{I}, '<div'));
    ndivs_closed_mine = ndivs_closed_mine + length(strfind(mine{I}, '/div'));
end

ndivs_dep
ndivs_closed_dep

ndivs_mine
ndivs_closed_mine