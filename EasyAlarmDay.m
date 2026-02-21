classdef EasyAlarmDay < matlab.apps.AppBase
    % Simple Alarm Clock with Day selection
    
    properties (Access = public)
        fig         matlab.ui.Figure
        timeLbl     matlab.ui.control.Label
        dayDrop     matlab.ui.control.DropDown
        hourSpin    matlab.ui.control.Spinner
        minSpin     matlab.ui.control.Spinner
        setBtn      matlab.ui.control.Button
        stopBtn     matlab.ui.control.Button
        statusLbl   matlab.ui.control.Label
    end
    
    properties (Access = private)
        t           % timer
        alarmDay    % day of alarm (date)
        alarmH      % alarm hour
        alarmM      % alarm minute
        alarmOn = false
    end
    
    methods (Access = private)
        
        function makeUI(app)
            % Window
            app.fig = uifigure('Position',[500 300 380 270], 'Name','Alarm with Day');
            
            % Time label
            app.timeLbl = uilabel(app.fig, ...
                'Position',[50 190 280 50], ...
                'FontSize',28, ...
                'HorizontalAlignment','center', ...
                'Text','00:00:00');
            
            % Day dropdown
            uilabel(app.fig,'Position',[60 160 60 20],'Text','Day');
            app.dayDrop = uidropdown(app.fig, ...
                'Position',[60 135 120 25], ...
                'Items',{'Today','Tomorrow'}, ...
                'Value','Today');
            
            % Hour spinner
            uilabel(app.fig,'Position',[200 160 40 20],'Text','Hour');
            app.hourSpin = uispinner(app.fig,'Limits',[0 23], ...
                'Position',[200 135 60 25]);
            
            % Minute spinner
            uilabel(app.fig,'Position',[270 160 40 20],'Text','Min');
            app.minSpin = uispinner(app.fig,'Limits',[0 59], ...
                'Position',[270 135 60 25]);
            
            % Set button
            app.setBtn = uibutton(app.fig,'Text','Set Alarm', ...
                'Position',[60 95 120 30], ...
                'ButtonPushedFcn',@(btn,event)setAlarm(app));
            
            % Stop button
            app.stopBtn = uibutton(app.fig,'Text','Stop Alarm', ...
                'Position',[200 95 120 30], ...
                'ButtonPushedFcn',@(btn,event)stopAlarm(app));
            
            % Status
            app.statusLbl = uilabel(app.fig, ...
                'Position',[60 60 250 22], ...
                'Text','No Alarm');
        end
        
        function updateTime(app)
            % Show live time
            nowT = datetime('now');
            app.timeLbl.Text = datestr(nowT,'dd-mmm HH:MM:SS');
            
            % Check alarm
            if app.alarmOn
                if day(nowT)==day(app.alarmDay) && ...
                        month(nowT)==month(app.alarmDay) && ...
                        year(nowT)==year(app.alarmDay) && ...
                        hour(nowT)==app.alarmH && minute(nowT)==app.alarmM
                    app.statusLbl.Text = 'ALARM!!!';
                    for k=1:5, beep; pause(0.4); end
                    app.alarmOn = false; % auto reset after firing
                end
            end
        end
        
        function setAlarm(app)
            % Choose day
            nowT = datetime('now');
            if strcmp(app.dayDrop.Value,'Today')
                app.alarmDay = dateshift(nowT,'start','day');
            elseif strcmp(app.dayDrop.Value,'Tomorrow')
                app.alarmDay = dateshift(nowT+days(1),'start','day');
            end
            
            % Hour & minute
            app.alarmH = app.hourSpin.Value;
            app.alarmM = app.minSpin.Value;
            app.alarmOn = true;
            
            % Show confirmation
            app.statusLbl.Text = sprintf('Alarm set for %s %02d:%02d',...
                datestr(app.alarmDay,'dd-mmm'),app.alarmH,app.alarmM);
        end
        
        function stopAlarm(app)
            app.alarmOn = false;
            app.statusLbl.Text = 'No Alarm';
        end
        
    end
    
    methods (Access = public)
        function app = EasyAlarmDay
            makeUI(app);
            
            % Timer updates clock
            app.t = timer('ExecutionMode','fixedSpacing','Period',1, ...
                'TimerFcn',@(~,~)updateTime(app));
            start(app.t);
        end
        
        function delete(app)
            if ~isempty(app.t) && isvalid(app.t)
                stop(app.t); delete(app.t);
            end
            if isvalid(app.fig), delete(app.fig); end
        end
    end
end