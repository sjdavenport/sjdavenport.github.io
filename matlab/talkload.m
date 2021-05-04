%%%% A function to generate the talk html file

% Assign directory
global davenpor
webdir = [davenpor, 'Private_Projects/sjdavenport.github.io/'];
matdir = [davenpor, 'Private_Projects/sjdavenport.github.io/matlab/'];

% Read in table data
talkdata = readtable([matdir,'talkdata.xlsx']);

% Read in html templates
FID_mid_temp = fopen([matdir,'talks_middle_temp.txt'],'r');
middle_temp = textscan(FID_mid_temp, '%s', 'Delimiter','\n');
middle_temp = middle_temp{1};

% Close all open files
fclose all;

% Capitalize and assign table names
talkdata.Properties.VariableNames = capstr(talkdata.Properties.VariableNames);
tablenames = talkdata.Properties.VariableNames;

% Determine where the buttons are that need to be implemented
nprebuttoncolumns = 6;
ntalks = length(talkdata.Title);
nbuttons = length(tablenames) - nprebuttoncolumns;
button_matrix = zeros(ntalks, nbuttons);
for I = 1:ntalks
    for J = 1:nbuttons
        if iscell(talkdata{I,J+nbuttons-1})
            talk_mate_entry = lower(talkdata{I,J+nbuttons-1}{1});
            if ~(strcmp(talk_mate_entry, 'na') || strcmp(talk_mate_entry, 'nan') || ...
                    (length(talk_mate_entry) == 1 && isnan(talk_mate_entry)))
                button_matrix(I,J) = 1;
            end
        end
    end
end
button_names = cell(1,nbuttons);
for b = 1:nbuttons
    button_names{b} = tablenames{b+nprebuttoncolumns};
end

% Button link table
button_indicator_table = array2table(button_matrix);
button_indicator_table.Properties.VariableNames = button_names;

%%% Get button headers
for I = 1:ntalks
    % Obtain the storage folder for the data for slides and posters
    folder = talkdata.Uni{I};
    if strcmp(talkdata.Department{I}, 'BDI')
        folder = 'BDI';
        talkdata.Department{I} = 'Big Data Institute';
    elseif strcmp(folder, 'King Adullah University of Science and Technology')
        folder = 'KAUST';
    elseif ~isempty(strfind(talkdata.Department{I}, 'OHBM'))
        folder = 'OHBM';
    elseif ~isempty(strfind(talkdata.Department{I}, 'Stats')) || ~isempty(strfind(talkdata.Department{I}, 'stats'))
        talkdata.Department{I} = 'Department of Statistics';
    else
        folder = 'Oxford';
    end
    
    % Add University of where needed
    if strcmp(talkdata.Uni{I}, 'Oxford') || strcmp(talkdata.Uni{I}, 'Warwick')
        talkdata.Uni{I} = ['University of ', talkdata.Uni{I}];
    end
    
    if button_indicator_table.Slides(I) == 1
        talkdata.Slides{I} = ['/talks/', folder, '/', talkdata.Slides{I}, '.pdf'];
    elseif button_indicator_table.Poster(I) == 1
        talkdata.Poster{I} = ['/talks/', folder, '/', talkdata.Poster{I}, '.pdf'];
    end
    
    % Replace the toolboxes with the link to the github
    if button_indicator_table.Toolbox(I)
        talkdata.Toolbox{I} = ['https://github.com/sjdavenport/', talkdata.Toolbox{I}, '/'];
    end
    
    % Replace the code links with the link to the github
    if button_indicator_table.Code(I)
        talkdata.Code{I} = ['https://github.com/sjdavenport/', talkdata.Code{I}, '/'];
    end
end

%
years = zeros(ntalks, 1);
for I = 1:ntalks
    %     year(I) = datestr(datenum(date(I,:),'dd-mm-yy',2000),'yyyy');
    years(I) = str2double(datestr(talkdata.Date(I,:),'yyyy'));
end
setofyears = flipud(unique(years));

celldocument = cell(1);

yearstart = 1;
year_refs = [1,2,4,5];
yearlinecount = 5;
talk_refs = [7,8,10,14,15,19] - yearlinecount;
% talk_newline_refs = [6,11,13,16,18] - yearlinecount;
talklinecount = 14; %Including the new line before each talk!

button_refs = [23,25];

startinputfrom = 0; %Note this will always be 1 less than the point at whcih you start input

talk_counter = ntalks; %Note that the talk counter starts from the most recent talk
for I = 1:length(setofyears)
    
    % Add default from template (to head up each year)
    for J = 1:length(year_refs)
        celldocument{startinputfrom + year_refs(J)} = middle_temp{year_refs(J)};
    end
    
    % Set year
    celldocument{startinputfrom + 3} = strrep(middle_temp{3}, 'YEAR', num2str(setofyears(I)));
    
    % Obtain the number of talks in the specified year
    talksinthisyear = (years == setofyears(I));
    
    % Update startinput from
    startinputfrom = startinputfrom + yearlinecount;
    
    % Write out the talks for this year
    for J = 1:sum(talksinthisyear)
        % Add default lines from template for each talk
        for K = 1:length(talk_refs)
            celldocument{startinputfrom + talk_refs(K)} = middle_temp{talk_refs(K) + yearlinecount};
        end
        
        % Add talk title
        celldocument{startinputfrom + 9 - yearlinecount} = strrep(middle_temp{9}, 'TITLE', talkdata.Title{talk_counter});
        
        % Add date
        celldocument{startinputfrom + 12 - yearlinecount} = datestr(talkdata.Date(talk_counter,:),'mmmm dd, yyyy');
        
        % Add Department, University and Country
        celldocument{startinputfrom + 17 - yearlinecount} = [talkdata.Department{talk_counter},', ',...
            talkdata.Uni{talk_counter},', ', talkdata.Country{talk_counter}];
        
        % startinputfrom = startinputfrom +talklinecount
        
        % Update start input vector
        startinputfrom = startinputfrom + talklinecount;
        
        % %% Add Buttons
        talk_button_locs = find(button_matrix(talk_counter,:));
        if ~isempty(talk_button_locs)
            celldocument{startinputfrom + 1} = middle_temp{20};
            startinputfrom = startinputfrom + 2; %Skip a line to leave a space!
            for K = 1:length(talk_button_locs)
                celldocument{startinputfrom + 1} = strrep(middle_temp{22}, 'BUTTONLINK', talkdata{talk_counter, talk_button_locs(K) + nprebuttoncolumns}{1});
                celldocument{startinputfrom + 2} = middle_temp{23};
                celldocument{startinputfrom + 3} = strrep(middle_temp{24}, 'BUTTONNAME', button_names{talk_button_locs(K)});
                celldocument{startinputfrom + 4} = middle_temp{25};
                startinputfrom = startinputfrom + 5;
            end
            
            % Add the closing /divs
            celldocument{startinputfrom + 1} = middle_temp{27};
            startinputfrom = startinputfrom + 1;
        end
        celldocument{startinputfrom + 1} = middle_temp{28};
        
        % Update talk and start input counters
        startinputfrom = startinputfrom + 1;
        talk_counter = talk_counter - 1;
    end
    
    % Add the closing /divs
    celldocument{startinputfrom + 1} = '</div>';
    celldocument{startinputfrom + 2} = '</div>';
    
    % Update startinput
    startinputfrom = startinputfrom + 3;
end

% Read header and footer files
fid_header = fopen([matdir,'talks_header.txt'],'r');
fid_footer = fopen([matdir,'talks_footer.txt'],'r');
header_data = textscan(fid_header, '%s', 'Delimiter','\n');
footer_data = textscan(fid_footer, '%s', 'Delimiter','\n');

% Open talk text file
fid = fopen([webdir, '/talks/index.html'], 'w');
addtext(fid, header_data{1})
addtext(fid, celldocument)
addtext(fid, footer_data{1})
fclose all;

% fid = fopen([webdir, '/talks/test.html'], 'w');
% addtext(fid, header_data{1})
% fclose all
% for I = 1:ntalks
%
% end
% for K = 1:2
%        fprintf(fid,  [middle_temp{K},'\n']);
%     end
%     fprintf(fid, [strrep(middle_temp{3}, 'YEAR', num2str(setofyears(I))),'\n']);
%     for K = 4:5
%        fprintf(fid, [middle_temp{K},'\n']);
%     end
%     fprintf(fid, '\n');

% % Add new lines
%         for K = 1:length(newlinerefs)
%             celldocument{startinputfrom + talk_newline_refs{K}} = '\n';
%         end

% % Convert table names to variables
% for I = 1:length(tablenames)
%     eval([tablenames{I},' = talkdata.', tablenames{I}]);
% end