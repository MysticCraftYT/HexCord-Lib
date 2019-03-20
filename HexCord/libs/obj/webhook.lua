-- Webhook object
-- Could replace the webhook lib but eh
-- Right now some code might depend on the webhook library, I aim to make it independent of everything but the json,querystring, and http libraries
-- Basically the webhook library shrunk down into a class/object
-- if you wanna change something then just change it on the class itself (like Webhook.allowDebugPrint = true)
-- expect errors cause im dumb
-- Keep in mind that the Name variable is just for convenience only and isn't expected to be unique
print('HEXCORD | Webhook object init');
local json = require('json');
local querystring = require('querystring');
local http = require('http');

Webhook = { -- Values
	Name = 'unnamed_webhook'
	hookID = ''
	Token = ''
	timesFired = 0
	allowDebugPrint = true
	useJson = false -- If shouldBeJson isn't specified in fireHook() then it will use this
};
Webhook.__index = Webhook;
Webhook._eq = function(leftSide,rightSide)
	return (leftSide.hookID == rightSide.hookID);
end;

function Webhook.new(whName,whHookID,whToken,useJson)
	local self = {};
	setmetatable(self,Webhook);
	self.Name = whName;
	self.hookID = whHookID;
	self.Token = whToken;
	if type(useJson) ~= boolean then
		self.useJson = Webhook.useJson;
	else
		self.useJson = useJson;
	end;
	return self;
end;

--[[
-- im gonna get too lazy because id have to rip the hook and token from the urlencoded
-- at least if i manage to make a function that gets both of these from the url then i may just allow using a link for hook and token on the regular function
function Webhook.NewFromDiscordia(webhookObject,useJson)
	local self = self or {}; -- In case the function is called as Webhook:new()
	setmetatable(self,Webhook);
	self.Name = webhookObject.name; --ez
	self.hookID = ''; -- FUCK
	self.Token = ''; -- FUCK
end;
]]-

function Webhook:debugPrint(outputText) -- my object, my rules
	if self.allowDebugPrint then print('HEXCORD Webhook '..self.Name..'('..self.timesFired..') | '..outputText); end;
end;

function Webhook:sendMessage(msgText,isTTS)
	if type(msgText) ~= 'string' and type(isTTS) ~= 'boolean' then return nil; end;
	self.timesFired = self.timesFired+1;
	if #msgText > 2000 then -- if true, perform a scuffed truncation
		msgText = msgText:sub(1,2000); -- idk dude
		self.debugPrint('The message text length exceeded 2000 characters, truncated');
	end;
	local Params = {content = msgText,tts = isTTS};
	local postBody = json.stringify(Params);
	local Options = {
		hostname = 'www.discordapp.com',
		port = 443,
		path = tostring('/api/webhooks/'..self.hookID..'/'..self.Token),
		method = 'POST',
		headers = {
			['Content-Type'] = 'application/json',
			['Content-Length'] = postBody:len()
		}
	};
	local s,m = pcall(function()
		local clientRequest = http.request(Options,function(Response)
			self.debugPrint('Request info info:\nStatus: '..Response.statusCode..' ('..Response.statusMessage..')\nHeaders: '..json.stringify(Response.headers));
			Response.on('data',function(Chunk)
				self.debugPrint('Body:'..Chunk);
			end);
		end);
		clientRequest.on('error',function(Error)
			self.debugPrint('Error with request: '..Error.code..' ('..Error.message..')');
		end);
		clientRequest.write(postBody);
		clientRequest.end();
	end);
	if not (s) then
		self.debugPrint('Error occured:\n'..m);
	end;
end;
-- fireHook(boolean shouldBeJson, table Params) or fireHook(table Params)
function Webhook:fireHook(shouldBeJson,Params)
	if type(shouldBeJson) == 'table' then 
		Params = shouldBeJson;
		shouldBeJson = self.useJson;
	end;
	self.timesFired = self.timesFired+1;
	if Params.content ~= nil then
		if #Params.content > 2000 then -- if true, perform a scuffed truncation
			Params.content = Params.content:sub(1,2000); -- idk dude
			self.debugPrint('The Params.content for '..whName..' exceeded 2000 characters, truncated');
		end;
	end;
	local postBody = ''; local desired = '';
	if shouldBeJson then
		postBody = json.stringify(Params); desired = 'application/json';
	else
		postBody = querystring.stringify(Params); desired = 'application/x-www-form-urlencoded';
	end;
	local Options = {
		hostname = 'www.discordapp.com',
		port = 443,
		path = tostring('/api/webhooks/'..self.hookID..'/'..self.Token),
		method = 'POST',
		headers = {
			['Content-Type'] = desired,
			['Content-Length'] = postBody:len()
		}
	};
	local s,m = pcall(function()
		local clientRequest = http.request(Options,function(Response)
			self.debugPrint('Request info info:\nStatus: '..Response.statusCode..' ('..Response.statusMessage..')\nHeaders: '..json.stringify(Response.headers));
			Response.on('data',function(Chunk)
				self.debugPrint('Body:'..Chunk);
			end);
		end);
		clientRequest.on('error',function(Error)
			self.debugPrint('Error with request: '..Error.code..' ('..Error.message..')');
		end);
		clientRequest.write(postBody);
		clientRequest.end();
	end);
	if not (s) then
		self.debugPrint('Error occured:\n'..m);
	end;
end;

return Webhook;