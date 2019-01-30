local Utils = {};
print('HEXCORD | Util init');
math.randomseed(os.time());
function Utils:Wait(num)
	if (type(num) ~= 'number') then num = 0.03; end;
	if (num > 0.03) then num = 0.03; end;
	print(tostring('HEXCORD | Wait called, '..num..' secs ('..num*1000..' microsecs)'));
	Timer.sleep(num*1000);
end;

-- Props to SinisterRectus/Discordia
function Utils:randomString(Length,Min,Max)
	local tableToReturn = {};
	if type(Min) ~= 'number' then Min = 0; end;
	if type(Max) ~= 'number' then Max = 255; end;
	for i = 1,Length do
		table.insert(tableToReturn,string.char(math.random(Min,Max)));
	end;
	return table.concat(tableToReturn);
end;

function Utils:Clamp(inputNum, Min, Max)
	return math.min(math.max(inputNum, Min), Max);
end;

function Utils:Round(n, i)
	local m = 10 ^ (i or 0);
	return math.floor(n * m + 0.5)/m;
end;
-- End of SR's props

-- Props to Crazyman32
function Utils:crazyNaturalSort(tbl)
	local function Convert(s)
		local res = ''; local dot = '';
		for n, m, c in tostring(s):gmatch("(0*(%d*))(.?)") do
			if (n == "") then
				dot, c = "", dot .. c
			else
				res = res .. (dot == "" and ("%03d%s"):format(#m, m) or "." .. n)
				dot, c = c:match("(%.?)(.*)")
			end
			res = res .. c:gsub(".", "\0%0")
		end
		return res
	end
	table.sort(tbl, function(a, b)
		local ca = Convert(a); local cb = Convert(b);
		return (ca < cb or ca == cb and a < b);
	end);
	return tbl;
end;

-- Props to Anaminus
function Utils:anamNaturalSort(tbl)
	table.sort(tbl,function(a,b)
		-- Split string by first sequence of digits.
		local function findNum(s)
			local i, j, n = s:find("(%d+)")
			if not i then
				return s, 0, ""
			end
			-- Return prefix, number, suffix
			return s:sub(1, i-1), tonumber(n), s:sub(j+1)
		end

		local apfx, anum, bpfx, bnum
		while true do
			if b == "" then
				return false -- b < a
			end
			if a == "" then
				return true -- a < b
			end
			apfx, anum, a = findNum(a)
			bpfx, bnum, b = findNum(b)
			if apfx ~= bpfx then
				return apfx < bpfx
			end
			if anum ~= bnum then
				return anum < bnum
			end
		end
	end);
	return tbl;
end;

-- Props to MemoryPenguin
-- I'm aware that Luvit already has a levenshtein function (string.levenshtein())
function Utils:Levenshtein(a,b)
	if a == b then return 0; end;
	if #a == 0 then return #b; end;
	if #b == 0 then return #a; end;
	--[[These are the two rows that we care about
		Traditional implementations of Wagner-Fischer use a full matrix
		This is unnecessary if the only objective is to retrieve the edit distance.
		If the goal is the edit distance alone, we only need to know the last and current rows.]]--
	local last = {};
	local current = {};
	-- Initialize the starting state of the last row, starting from 0.
	for i = 1, #b+1 do
		last[i] = i-1;
	end;
	-- For each character in the first string...
	for charA = 1,#a do
		-- Initialize current to the value of i.
		current[1] = charA;
		-- For each character in the second string
		for charB = 1,#b do
			-- If the two characters differ, we're performing an operation, be it substitution, deletion, or addition.
			if string.sub(a,charA,charA) ~= string.sub(b,charB,charB) then
				current[charB+1] = math.min(current[charB]+1,last[charB+1]+1,last[charB]+1); -- Insertion, Deletion, Substitution, respectfully
			else -- If they're the same, the edit distance hasn't changed and we can use the one from the previous column and row.
				current[charB+1] = last[charB];
			end;
		end;
		--[[Overwrite the last row with the current row when we're done.
			We don't swap the tables because that would create a new table, with all its allocation and resizing costs.]]--
		for i = 1,#b+1 do
			last[i] = current[i];
		end;
	end;
	-- The final edit distance will be the value in the final column of the final row.
	return current[#b+1];
end;

function Utils:shuffleTable(tableToShuffle,shushPlease)
	if type(shushPlease) ~= 'boolean' then shushPlease = false; end;
	local sms,smm = pcall(function() table.sort(tableToShuffle); end);
	if sms == false and shushPlease == false then
		print('HEXCORD | Table sort failed: '..smm..'\nTraceback:\n'..debug.traceback());
	end;
	local tableToReturn = {};
	while true do
		if #tableToShuffle == 0 then
			break;
		end;
		local ourIndex = math.random(1,#tableToShuffle);
		local ourValue = tableToShuffle[ourIndex];
		table.insert(tableToReturn,#tableToReturn+1,ourValue);
		table.remove(tableToShuffle,ourIndex);
	end;
	return tableToReturn;
end;

function Utils:ranAlphanumericStr(Length,omitNumbers)
	local tableToReturn = {};
	local acceptableRanges = {
		{65,90},{97,122},{48,57} -- uppercase, lowercase, numbers
	};
	if omitNumbers then acceptableRanges[3] = nil; end;
	for i = 1,Length do
		local ranSet = math.random(1,#acceptableRanges);
		table.insert(tableToReturn,string.char(math.random(acceptableRanges[ranSet][1],acceptableRanges[ranSet][2])));
	end;
	return table.concat(tableToReturn);
end;

function Utils:randomPickFromTable(tableToPick)
	if #tableToPick > 14 then -- Don't want to shuffle small tables, could get expensive
		tableToPick = Utils:shuffleTable(tableToPick);
		tableToPick = Utils:shuffleTable(tableToPick,true);
	end;
	return tableToPick[math.random(1,#tableToPick];
end;

function Utils:getSizeOfFile(filePath)
	local statData = nil;
	fs.Stat(filePath,function(errors,statObj)
		if (errors) then
			return nil, errors;
		else
			statData = statObj;
		end;
	end);
	local sizeTable = {B=0,KB=0,MB=0,GB=0};
	sizeTable.B = statData.size;
	sizeTable.KB = sizeTable.B/1000;
	sizeTable.MB = sizeTable.KB/1000;
	sizeTable.GB = sizeTable.MB/1000;
	return sizeTable;
end;

-- something i thought of
-- this is stupid
-- i made this on a calculator and then wrote it in lua
-- im very bored
Utils.RandomVars = {a = 0, b = 0, c = 0, d = 0, e = 0, f = 0};
function Utils.weirdRandom()
	local Varq = Utils.RandomVars;
	Varq.a = (math.random(-40,45)+math.floor(Varq.f/4));
	Varq.b = (Varq.a+Varq.f-math.floor(Varq.a/2));
	Varq.c = (Varq.b-Varq.a+math.random(-20,20));
	Varq.d = (Varq.c-math.floor(Varq.c/2)-(Varq.a-Varq.b)+(Varq.e+Varq.d));
	Varq.e = ((Varq.b+Varq.a)-(Varq.f-Varq.a));
	Varq.f = (math.random(-45,45)+(Varq.c+Varq.a)-(Varq.e+Varq.d));
	return Varq.f,Varq;
end;

-- replacement for the plain lua (condition and trueVar or falseVar)
function Utils.Either(Condition,trueVar,falseVar)
	if (Condition) return trueVar; else return falseVar; end;
end;

function Utils.XOr(fCon,sCon)
	if fCon == sCon then return false;
	elseif fCon == true and sCon == false then return true;
	elseif sCon == true and fCon == false then return true;
	else return false; -- failsafe cause im lazy
	end;
end;

return Utils;