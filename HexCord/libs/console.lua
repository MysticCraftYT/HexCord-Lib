local Console = {};
print('HEXCORD | Console init');
math.randomseed(os.time());
function Console.Timeout(Secs,allowBreak)
	if type(Secs) ~= 'number' then return nil; end;
	if type(AllowBreak) ~= 'boolean' then allowBreak = true; end;
	Secs = math.floor(Secs);
	if Secs <= -1 then Seconds = -1; allowBreak = true; end; -- Effectively pause
	-- if Secs == 0 then print('HEXCORD | Redundant to call timeout with 0 seconds'); return nil; end;
	if Secs == 0 then allowBreak = false; end;
	if not AllowBreak then
		os.execute('timeout /t '..Secs..' /nobreak');
	else
		os.execute('timeout /t '..Secs); -- if 0 then it just pauses the code for a split sec while timeout.exe opens and closes itself
	end;
end;

function Console.Clear()
	os.execute('cls');
end;
Console.ClearScreen = Console.Clear;

function Console.Pause()
	os.execute('pause');
end;

function Console.Title(Str)
	Str = tostring(Str);
	if Str ~= nil then os.execute('title '..Str); end;
end;
Console.ChangeWindowTitle = Console.Title;

-- expects to be running as admin
function Console.SimpleTaskkill(taskname)
	if taskname:match('%.exe$') == '.exe' then
		os.execute('taskkill /F /IM '..taskname);
	else
		os.execute('taskkill /F /IM '..taskname..'.exe');
	end;
end;
-- expects to be running as admin
function Console.TaskkillByPID(taskPID)
	os.execute('taskkill /F /PID '..taskPID);
end;

-- I may have overcomplicated this.
function Console.getColorNumber(a)
	local validC = {'a'=true,'b'=true,'c'=true,'d'=true,'e'=true,'f'=true};
	if type(a) == 'string' then
		a = a:lower();
		if a == 'blvit friendlyack' or a == 'white' then a = 0; -- the blvit thing was an accident lol
		elseif a == 'blue' then a = 1;
		elseif a == 'green' then a = 2;
		elseif a == 'aqua' then a = 3;
		elseif a == 'red' then a = 4;
		elseif a == 'purple' then a = 5;
		elseif a == 'yellow' then a = 6;
		elseif a == 'white' then a = 7;
		elseif a == 'gray' then a = 8;
		elseif a == 'lblue' then a = 9; -- light colors
		elseif a == 'lgreen' then a = 'a';
		elseif a == 'laqua' then a = 'b';
		elseif a == 'lred' then a = 'c';
		elseif a == 'lpurple' then a = 'd';
		elseif a == 'lyellow' then a = 'e';
		elseif a == 'bwhite' then a = 'f'; -- bright white
		elseif #a == 1 then
			if not validC[a] then
				return nil;
			end;
		else return nil;
		end
	elseif type(a) == 'number' then
		if a < 0 or a > 9 then 
			return nil;
		end;
	end;
	return a;
end;

-- makes the console have random background and foreground colors (a bit big since you cant have back and fore as the same color)
function Console.randomColors()
	local ranTable = {0,1,2,3,4,5,6,7,8,9,'a','b','c','d','e','f'};
	local backC; local foreC;
	local CI = math.random(1,#ranTable);
	backC = ranTable[CI];
	table.remove(ranTable,CI);
	local CI = math.random(1,#ranTable);
	foreC = ranTable[CI];
	os.execute('color '..backC..''..foreC);
end;

function Console.setColor(Background,Foreground)
	Background = Console.getColorNumber(Background);
	Foreground = Console.getColorNumber(Foreground);
	if Background == Foreground then
		print('HEXCORD | You may not use the same background and foreground');
		return false;
	else
		os.execute('color '..Background..''..Foreground);
	end;
end;

return Console;


















