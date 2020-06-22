function talkdata = newtalk
% NEWTALK adds the latest talk data to the excel file and generates the
% required html file
%--------------------------------------------------------------------------
% ARGUMENTS: No arguments, this are obtained
%--------------------------------------------------------------------------
% OUTPUT
% Updates the excel file and generates html
%--------------------------------------------------------------------------
% EXAMPLES
% newtalk
%--------------------------------------------------------------------------
% AUTHOR: Samuel Davenport
%--------------------------------------------------------------------------

% Obtain data for the new talk
global davenpor
webdir = [davenpor, 'Private_Projects/sjdavenport.github.io/matlab/'];

% Read in table data
talkdata = readtable([webdir,'talkdata.xlsx']);
ntalks = size(talkdata,1);
noptions = size(talkdata,2);

% Obtain the table names
tablenames = capstr(talkdata.Properties.VariableNames);

% Generate example data
extable = cell2table(cell(1,length(tablenames)));
extable.Properties.VariableNames = tablenames;

nprebuttonoptions = 6;
nbuttons = noptions - nprebuttonoptions;
exclusions = 3;
prebuttonoptions2include = setdiff(1:nprebuttonoptions, exclusions);

% Generate option list
button_option_list = '(0) No action,';
for I = 1:nbuttons
    button_option_list = [button_option_list, ', (', num2str(I),')', tablenames{I+nprebuttonoptions}]; %#ok<AGROW>
end
all_option_list = '(0) Continue,';
rel_options = setdiff(1:noptions, exclusions);
for I = 1:rel_options
    all_option_list = [all_option_list, ',(', num2str(I), ')', tablenames{rel_options}]; %#ok<AGROW>
end

for I = 1:length(prebuttonoptions2include)
    extable{1,prebuttonoptions2include(I)}{1} = input([tablenames{prebuttonoptions2include(I)}, ': '], 's');
end
keepaddingbuttons = 1;
while keepaddingbuttons == 1
    buttonoption = input(['The options are:', button_option_list, '\n']);
    if buttonoption > 0
        extable{nprebuttonoptions + buttonoption} = input([tablenames{nprebuttonoptions + buttonoption},': '], 's');
    else
        keepaddingbuttons = 0;
    end
end

extable
cont2go = input('Is this table ok? (0: no, 1: yes) \n');
while cont2go ~= 1
    if cont2go == 0
        changebutton = input([all_option_list, '\n'], 's');
        if changebutton == 0 
            cont2go = 1;
        else
            if changebutton > 5
                changebutton = changebutton + length(exclusions);
            end
            extable{changebutton} = input([tablenames{changebutton},':'], 's');
        end
    end
end

% Add the new talk data
talkdata{ntalks+1,:} = extable.Variables;

% % Write the table to the file
% writetable(talkdata, [webdir,'talkdata.xlsx'])
% 
% % Load the html document
% talkload

end

