cd 'C:\Users\Shevc\Dropbox\7. semester\Procesregulering\Week_03_Tennessee_Eastman\Exercises\To Students\To Students'

function TEP_GUI_v008
% C. Bayer / 2017-09-01 / v008
% -- GUI to Ricker Open-Loop Simulation
% -- Simulink Simulation slowed-down
% -- All input values except 2 can be changed, 2 are controlled
% -- All input values are plotted
% -- Six outputs are visualized
% -- Alarms are in place (table 6 of Downs1993); graph titles turn red
% -- write CSV on request

close all;

open_system('tesys');
%set_param('tesys', 'AlgebraicLoopSolver', 'LineSearch');

%% Initializing Windows
% Main Control Figure
f = figure(...
    'Visible','on',...
    'Name','TEP GUI to Simulink',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Position',[5,60,800,320]...
    );

% Input Figure
fIn = figure(...
    'Visible','off',...
    'Name','Input Figures',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Position',[5,120,1024,1000/sqrt(2)]...
    );

% Output Figure
fOut = figure(...
    'Visible','off',...
    'Name','Output Figures',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'Position',[500,120,1024,1000/sqrt(2)]...
    );


%% Filling Windows with Content
% --- Main Window ---
figure(f);
% Controls
hstartsim = uicontrol('Style','pushbutton',...
             'String','Start TEP-Simulation','Position',[715,220,70,25],...
             'Interruptible','off',...
             'Callback',@startsimbutton_Callback);
         
% 'TooltipString','Interruptible = off',...
% 'Interruptible','off',...

% 'BusyAction','cancel',...
% 'BusyAction','queue',...

hstopvalue = uicontrol('Style','pushbutton',...
             'String','Stop','Position',[715,180,70,25],...
             'BusyAction','queue',...
             'Callback',@stopsimbutton_Callback);       
  
hWriteCSV = uicontrol('Style','pushbutton',...
             'String','Write CSV','Position',[715,140,70,25],...
             'BusyAction','queue',...
             'Callback',@writeCSVbutton_Callback);
         
         
% hsetvalue = uicontrol('Style','pushbutton',...
%              'String','Set Value','Position',[715,140,70,25],...
%              'BusyAction','queue',...
%              'Callback',@setvaluebutton_Callback);
% 
% 
% htxtbox  = uicontrol('Style','edit', ...
%             'String','',...
%             'UserData', [0 100], ...
%             'Position',[615,140,70,25],...
%             'Callback',@changevalue_Callback);

%set(htxtbox, 'KeyPressFcn',@key_pressed_fcn);
% lh = addlistener(src,'StateChange',@handleStateChange)

columnname = {'Variable', 'Number', 'Value', 'Low Limit','High Limit','Plot'};
columnformat = {'char', 'char', 'numeric','numeric','numeric','logical'};

% rowname = { ;...
%             'XMV 2:';...
%             'XMV 3:';...
%             'XMV 4: '; ...
%             'XMV 5: Compr. Recycle Valve'; ...
%             'XMV 6: '; 
%             'XMV 7: '; ...
%             'XMV 8: '; ...
%             'XMV 9: '; ...
%             'XMV 10: '; ...
%             'XMV 11: '; ...
%             'XMV 12: ';};
% Define the data
d =    {'D Feed (Stream 2)',                'XMV 1', 63.053, 0, 100, true;...
        'E Feed (Stream 3)',                'XMV 2', 53.980, 0, 100, true;...
        'A Feed (Stream 1)',                'XMV 3', 24.644, 0, 100, true;...
        'C+A Feed (Stream 4)',              'XMV 4', 61.302, 0, 100, true;...
        'Compr. Recycle Valve',             'XMV 5', 22.210, 0, 100, true;...
        'Purge Valve (Stream 6)',           'XMV 6', 40.064, 0, 100, true;...
        'Flash Liq. Outflow (Stream 10)',   'XMV 7', 38.100, 0, 100, true;...
        'Stripper Liq. Product (Stream 11)','XMV 8', 46.534, 0, 100, true;...
        'Stripper Steam Valve',             'XMV 9', 47.446, 0, 100, true;...
        'Reactor Cooling Water Flow',       'XMV 10', 41.106, 0, 100, true;...
        'Condenser Cooling Water Flow',     'XMV 11', 18.114, 0, 100, true;...
        'Agitator Speed',                   'XMV 12', 50.000, 0, 100, true;};

% Create the uitable
t = uitable('Data', d,... 
            'ColumnName', columnname,...
            'ColumnFormat', columnformat,...
            'ColumnWidth', {220  60  'auto'  'auto'  'auto'  'auto'},...
            'ColumnEditable', [false false true false false true],...
            'RowName',[ ], ...
            'CellEditCallback',@edittable_callback);

% General information
t_dim = size(t.Data);

% Set width and height
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);  

% Set Value in Table
%t.Data(1,3) = num2cell(55);
%disp(cell2mat(t.Data(1,3)));


% --- Input Plot Window ---
figure(fIn);

% Create Dummy Data to plot
x = linspace(-5,5); % define x
y1 = sin(x); % define y1

% Create Subfigures
% -- no. of plots for table --
np = t_dim(1);
nr = floor(sqrt(np));
nc = ceil(np/nr);

% Create persistent variable for data tracking
%s = f.UserData;
%f.UserData.xmv{1} = [0 0; 0 cell2mat(d(1,3))];
%f.UserData.xmv{2} = [0 0; 1 cell2mat(d(1,3))];
tout = [1];
yout2 = zeros(1,12);

1;
for i = 1:12 %(nc*nr)
    subplot(nr,nc,i);
    f.UserData.h_fig{i} = plot(tout, yout2(:,i));
    title(t.Data(i,1),...
        'FontSize', 10);
    ylim([0 100]);

    set(f.UserData.h_fig{i}, 'XDataSource', 'tout', 'YDataSource', strcat('yout2(:,',num2str(i),')'));

end % for

% --- Output Plot Window ---
figure(fOut);

nr_out = 2;
nc_out = 3;

tout = [1];
yout = zeros(1,41);
fOut_titles = { {6 ,'XMEAS6: R Feed Rate'}; ...
                {7, 'XMEAS7: R pressure'}; ...
                {8, 'XMEAS8: R level'}; ...
                {9, 'XMEAS9: R temp.'}; ...
                {12, 'XMEAS12: Sep. level'}; ...
                {15, 'XMEAS15: Stripper level'} };


for i = 1:6 %(nc*nr)
    subplot(nr_out,nc_out,i);
    f.UserData.h_figOut{i} = plot(tout, yout(:,fOut_titles{i}{1}));
    title(fOut_titles{i}{2},...
        'FontSize', 10);
    set(f.UserData.h_figOut{i}, 'XDataSource', 'tout', 'YDataSource', strcat('yout(:,',num2str(fOut_titles{i}{1}),')'));

end % for


% Create Timer for auto-update
h_timer = timer(...
    'ExecutionMode', 'fixedRate', ...         % Run timer repeatedly.
    'Period', 2, ...                        % Initial period is 1 sec.
    'TimerFcn', {@update_display});  % Specify callback function.

% Index Log for limit Check
ii = 1;
ii_new = 1;

flag = zeros(41);

% Bring back up the main figure
figure(f);

%% Callbacks
function startsimbutton_Callback(source,eventdata) 
    set_param('tesys','SimulationCommand','start');
    if strcmp(get(h_timer, 'Running'), 'off')
        start(h_timer);
    end % if
end

function stopsimbutton_Callback(source,eventdata) 
    set_param('tesys','SimulationCommand','stop');
    if strcmp(get(h_timer, 'Running'), 'on')
        stop(h_timer);
    end % if
   
end

function writeCSVbutton_Callback(source,eventdata) 
        evalin('base', 'delete Mout;');
        evalin('base', 'Mout = [tout, yout2, yout];');
        evalin('base', 'csvwrite(''SimResults.csv'',Mout);');        
end

% function setvaluebutton_Callback(source,eventdata) 
%     set_param('tesys/xmv1','value',get(htxtbox,'String'));
% end
% 
% function changevalue_Callback(s,e) 
%         helpVar = str2double(get(s,'String'))
%         if  (~isnan(helpVar)) && (s.UserData(1) <= helpVar) && (helpVar <= s.UserData(2))
%             s.BackgroundColor = 'white';  % good input
%         else
%             s.BackgroundColor = 'red';  % bad input
%         end
% end


function key_pressed_fcn(s, e)
    if (strcmp(e.Key, 'return'))
        helpVar = str2double(get(s,'String'))
        if  (~isnan(helpVar)) && (s.UserData(1) <= helpVar) && (helpVar <= s.UserData(2))
            s.BackgroundColor = 'white';  % good input
        else
            s.BackgroundColor = 'red';  % bad input
        end
    end     
    
end

% Edit Table / Check Data / Write to Simulink                
function edittable_callback(h_Obj,cb_data)  % h_ handle; cb_ callback
    r = cb_data.Indices(1);                % row
    c = cb_data.Indices(2);                % column
    
    if c == 3   % Change Set Point
        v = str2double(cb_data.EditData);      % value
        if (~isnan(v)) && (h_Obj.Data{r,4} <= v) && (v <= h_Obj.Data{r,5})
            1;  % XXX: Write to Simulink
            set_param(strcat('tesys/xmv',int2str(r)),'value',num2str(v));
            xmv1t = [xmv1t; [0,1]];
            xmv1t = [0,1];
            %xmv1 = [xmv1; [get_param('tesys','SimulationTime'), h_Obj.Data{1,3}]];
           
        else
            h_Obj.Data{r,3} = cb_data.PreviousData;
        end % if
    
    elseif c == 6   % Change Plot Selection
%        nr = 0;          % no. of rows
        1;      % XXX: Update Plotting
%         for i=1:size(h_Obj.Data)    % no. of plots required
%             nr = nr + h_Obj.Data{i,6};
%         end % for
        figure(fIn);
        if h_Obj.Data{r,6} == 0
            subplot(nr,nc,r,'replace');
        else
            subplot(nr,nc,r);
            title(t.Data(r,1),...
                'FontSize', 10, ...
                ylim(0,100));
            plot(xmv1t(:,1),xmv1t(:,2))
        end % if
        figure(f)
    end % if

end % function

function update_display(h, e)
    set_param('tesys','SimulationCommand','pause');
    ii_new = evalin('base', 'length(tout);');
    for i = 1:12
        refreshdata(f.UserData.h_fig{i});
    end % for
    for i = 1:6
        refreshdata(f.UserData.h_figOut{i});
        % Check Limits --> New Function
        if fOut_titles{i}{1} == 7
              str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              maxVal = evalin('base', str);
              if maxVal >= 2895 && flag(7) == 0 % Reactor Pressure
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('High Limit: ', strcat(fOut_titles{i}{2})));
                      flag(7) = 1;
                      fOut.Children(5).Title.Color(1) = 1;
                      %keyboard;
                  end % if
              end % if
              if maxVal <= 2895 && flag(7) == 1
                  flag(7) = 0;
                  fOut.Children(5).Title.Color(1) = 0;
             end % if
        end % if
        if fOut_titles{i}{1} == 8 % Reactor Level
              str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              maxVal = evalin('base', str);
              str = strcat('min(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              minVal = evalin('base', str);
              if maxVal >= 100 && flag(8) == 0
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('High Limit: ', strcat(fOut_titles{i}{2})));
                      flag(8) = 1;
                      fOut.Children(4).Title.Color(1) = 1;
                  end % if
              end % if
              if maxVal <= 100 && flag(8) == 1
                  flag(8) = 0;
                  fOut.Children(4).Title.Color(1) = 0;
              end % if
              if minVal <= 50 && flag(8) == 0
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('Low Limit: ', strcat(fOut_titles{i}{2})));
                      flag(8) = -1;
                      fOut.Children(4).Title.Color(1) = 0.7;
                  end % if
              end % if
              if minVal >= 50 && flag(8) == -1
                  flag(8) = 0;
                  fOut.Children(4).Title.Color(1) = 0;
             end % if
        end % if
        if fOut_titles{i}{1} == 9 % Reactor Temperature
              str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              maxVal = evalin('base', str);
              if maxVal >= 150 && flag(9) == 0
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('High Limit: ', strcat(fOut_titles{i}{2})));
                      flag(9) = 1;
                      fOut.Children(3).Title.Color(1) = 1;
                   end % if
              end % if
              if maxVal <= 150 && flag(9) == 1
                  flag(9) = 0;
                  fOut.Children(3).Title.Color(1) = 0;
             end % if
        end % if
        if fOut_titles{i}{1} == 12 % Prod. Seperator Level
              str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              maxVal = evalin('base', str);
              str = strcat('min(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              minVal = evalin('base', str);
              if maxVal >= 100 && flag(12) == 0
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('High Limit: ', strcat(fOut_titles{i}{2})));
                      flag(12) = 1;
                      fOut.Children(2).Title.Color(1) = 1;
                      %keyboard;
                  end % if
              end % if
              if maxVal <= 100 && flag(12) == 1
                  flag(12) = 0;
                  fOut.Children(3).Title.Color(1) = 0;
              end % if
              if minVal <= 30 && flag(12) == 0
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('Low Limit: ', strcat(fOut_titles{i}{2})));
                      flag(12) = -1;
                      fOut.Children(2).Title.Color(1) = 0.7;
                      %keyboard;
                  end % if
              end % if
              if minVal >= 30 && flag(12) == -1
                  flag(12) = 0;
                  fOut.Children(3).Title.Color(1) = 0;
              end % if
        end % if
        if fOut_titles{i}{1} == 15 % Stripper Base Level
              str = strcat('max(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              maxVal = evalin('base', str);
              str = strcat('min(yout(', int2str(ii),':',int2str(ii_new),',',int2str(fOut_titles{i}{1}),'))');
              minVal = evalin('base', str);
              if maxVal >= 100 && flag(15) == 0
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('High Limit: ', strcat(fOut_titles{i}{2})));
                      flag(15) = 1;
                      fOut.Children(1).Title.Color(1) = 1;
                  end % if
              end % if
              if maxVal <= 100 && flag(15) == 1
                  flag(15) = 0;
                  fOut.Children(1).Title.Color(1) = 0;
              end % if
              if minVal <= 30 && flag(15) == 0
                  if ~(strcmp(get_param('tesys','SimulationStatus'), 'stopped'))
                      disp(strcat('Low Limit: ', strcat(fOut_titles{i}{2})));
                      flag(15) = -1;
                      fOut.Children(1).Title.Color(1) = 0.7;
                  end % if
              end % if
              if minVal >= 30 && flag(15) == -1
                  flag(15) = 0;
                  fOut.Children(1).Title.Color(1) = 0;
             end % if
        end % if
        
    end % for
    ii = ii_new;
    pause(1e-4);
    set_param('tesys','SimulationCommand','continue');
    
end % function

function alarm(p) %% not in use !!
    %uiwait; waitfor;
    dd = dialog('Position',[300 300 250 150],'Name','Alarm');
    
    txt = uicontrol('Parent',dd,...
               'Style','text',...
               'Position',[20 80 210 40],...
               'String',strcat('High limit:', p));

    btn = uicontrol('Parent',dd,...
               'Position',[85 20 70 25],...
               'String','Close',...
               'Callback','delete(gcf)');
           
    uiwait(dd);
end
    
end

