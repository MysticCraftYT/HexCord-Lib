-- Webhook object
-- Could replace the webhook lib but eh
-- Right now some code might depend on the webhook library, I aim to make it independent of everything but the json,querystring, and http libraries
-- Basically the webhook library shrunk down into a class/object
local json = require('json');
local querystring = require('querystring');
local http = require('http');

HCL.Webhook = { -- Values
	Name = ''
	hookID = ''
	Token = ''
	timesFired = 0
	overridesJson = true
};
HCL.Webhook.__index = Webhook;
HCL.Webhook._eq = function(leftSide,rightSide)
	return (leftSide.hookID == rightSide.hookID);
end;

function HCL.Webhook.new(whName,whHookID,whToken)
	local self = setmetatable({},self);
	self.Name = whName;
	self.hookID = whHookID;
	self.Token = whToken;
	return self;
end;

function HCL.Webhook:debugPrint(outputText) -- i need some help over here mk? my object, my rules
	print('HexCordLib Webhook Objects | '..self.Name..'('..self.timesFired..'): '..outputText);
end;

function HCL.Webhook:shouldOverrideJson(optionalSet)
	if type(optionalSet) ~= 'boolean' then return self.overridesJson; end;
	self.overridesJson = optionalSet;
end;

function HCL.Webhook:changeHookData(whHookID,whToken,shouldResetFireCount)
	self.hookID = whHookID;
	self.Token = whToken;
	if shouldResetFireCount then self.timesFired = 0; end;
end;

function HCL.Webhook:sendMessage(msgText,isTTS)
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

function HCL.Webhook:fireHook(shouldBeJson,Params)
	if type(shouldBeJson) == 'table' then 
		Params = shouldBeJson;
		shouldBeJson = not self.overridesJson;
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