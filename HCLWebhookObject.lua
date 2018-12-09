-- Webhook object
-- Could replace the webhook lib but eh
-- Right now some code might depend on the webhook library, I aim to make it independent of everything but the json,querystring, and http libraries
-- Basically the webhook library shrunk down into a class/object
-- if you wanna change something then just change it on the class itself (like Webhook.allowDebugPrint = true)
-- expect errors cause im dumb
-- Keep in mind that the Name variable is just for convenience only and isn't expected to be unique
print('HexCordLib | Webhook object loading');
local json = require('json');
local querystring = require('querystring');
local http = require('http');

HCL.Webhook = { -- Values
	Name = 'unnamed_webhook'
	hookID = ''
	Token = ''
	timesFired = 0
	allowDebugPrint = true
	useJson = false -- If shouldBeJson isn't specified in fireHook() then it will use this
};
HCL.Webhook.__index = Webhook;
HCL.Webhook._eq = function(leftSide,rightSide)
	return (leftSide.hookID == rightSide.hookID);
end;

function HCL.Webhook.new(whName,whHookID,whToken,useJson)
	local self = setmetatable({},self);
	self.Name = whName;
	self.hookID = whHookID;
	self.Token = whToken;
	if type(useJson) ~= boolean then
		self.useJson = false;
	else
		self.useJson = useJson;
	end;
	return self;
end;

function HCL.Webhook:debugPrint(outputText) -- my object, my rules
	if self.allowDebugPrint then print('HexCordLib Webhook Objects | '..self.Name..'('..self.timesFired..'): '..outputText); end;
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