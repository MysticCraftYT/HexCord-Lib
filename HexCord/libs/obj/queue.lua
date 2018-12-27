-- Basic queue object. Playlist, if you will.
-- I'm aware Discordia apparently has a queue object and a deque (double-ended queue object) but I can't be arsed to use it
-- Plus this is some good practice with writing objects
-- Keep in mind that the Name variable is just for convenience only and isn't expected to be unique
print('HEXCORD | Queue object init');
Queue = {
	Name = 'unnamed_queue' -- *smokes le good blunt*
	Queue = {} -- queue is just "Q" with 4 silent letters
};
Queue.__index = Queue;
Queue._eq = function(leftSide,rightSide)
	if #leftSide.Queue == #rightSide.Queue then
		for i,v in pairs(leftSide.Queue) do
			if v ~= rightSide.Queue[i] then return false; end;
		end;
		return true;
	end;
	return false;
end;

function Queue.new(Name,presetTable)
	local self = setmetatable({},self);
	self.Name = whName;
	self.Queue = presetTable;
	return self;
end;
-- Gets the value in the position requested or the first value
function Queue:Grab(Index)
	if type(Index) == 'string' then Index = tonumber(Index); end;
	if type(Index) ~= 'number' then Index = 1; end;
	if Index < 0 then Index = 1; end;
	if Index > #self.Queue then Index = #self.Queue; end;
	return self.Queue[Index];
end;
-- Gets the value in the position requested or the first value and removes it from the table
function Queue:Pop(Index)
	if type(Index) == 'string' then Index = tonumber(Index); end;
	if type(Index) ~= 'number' then Index = 1; end;
	if Index < 0 then Index = 1; end;
	if Index > #self.Queue then Index = #self.Queue; end;
	local valueToGet = self.Queue[Index];
	table.remove(self.Queue,Index);
	return valueToGet;
end;
-- Essentially skip one or some variables. maxIndexToRemove is optional
function Queue:Remove(indexToRemove,maxIndexToRemove)
	if type(indexToRemove) == 'string' then indexToRemove = tonumber(indexToRemove); end;
	if type(indexToRemove) ~= 'number' then indexToRemove = 1; end;
	if indexToRemove < 0 then indexToRemove = 1 end;
	if indexToRemove > #self.Queue then indexToRemove = #self.Queue; end;
	if type(maxIndexToRemove) == 'string' then maxIndexToRemove = tonumber(maxIndexToRemove); end;
	if type(maxIndexToRemove) ~= 'number' then maxIndexToRemove = indexToRemove; end;
	if maxIndexToRemove < indexToRemove then maxIndexToRemove = 1 end;
	local removedValues = {}; local indexesToRemove = {};
	for i,v in pairs(self.Queue) do
		if i > maxIndexToRemove then break; end;
		if i >= indexToRemove then
			table.insert(indexesToRemove,#indexesToRemove+1,i);
			table.insert(removedValues,#removedValues+1,v);
		end;
	end;
	for i,v in pairs(indexesToRemove) do table.remove(self.Queue,v); end;
	return removedValues;
end;
-- Add a value to the queue, overrideIndex is optional
function Queue:Add(Value,overrideIndex)
	if type(overrideIndex) == 'string' then overrideIndex = tonumber(Index); end;
	if type(overrideIndex) ~= 'number' then overrideIndex = #self.Queue+1; end;
	if overrideIndex < 0 then overrideIndex = #self.Queue+1; end;
	if overrideIndex > #self.Queue then overrideIndex = #self.Queue+1; end;
	table.insert(self.Queue,overrideIndex,Value);
end;
-- Clears the queue and returns it just in-case you want it
function Queue:Clear()
	local oldQueue = {};
	for i,v in pairs(self.Queue) do
		table.insert(oldQueue,i,v); -- Essentially quick copy the queue, works perfectly for arrays
	end;
	self.Queue = {};
	return oldQueue;
end;

return Queue;