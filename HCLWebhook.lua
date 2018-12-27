--[[ Discord Wehhook sub-library, by Kobal
	
	This is based off a Node.js module that does the same thing but it simply only sends messages to 1 hook
	This was originally its own thing
	Expect tons of errors attempting to use this
	
	Current tasks:
	- Make a robust webhook storage system.
	- Debug and test run code
	- Figure out how the clientRequest object works
	- Handle errors (pcall() with printing any errors will suffice for now)
	
	To-Do:
	- Easy embed creator (Might be time consuming)
	
	Webhook parameters table:
	Params = {
		content = A string, limited to 2000 characters | Content, file, or embeds is required
		username = A string to override the default name of the Webhook | Not required
		avatar_url = A string to override the default avatar of the hook (Possibly Base64, from what I know from Discordia | Not required
		tts = A bool indicating if the message will be Text to Speech | Not required
		file = Going to assume JSON doesn't support file uploads, use Urlencoded? | Content, file, or embeds is required
		embeds = An array of embeds, rich embedded content Link to docs: https://discordapp.com/developers/docs/resources/channel#embed-object | Content, file, or embeds is required
	};
	Disallowed fields in embeds in hooks:
	- type (Forced to be rich)
	- provider
	- video
	- any hight, width or proxy_url for images
]]--
print('HexCordLib Webhooks | Library called');
HCL = _G.HCL; -- necessary
local http = require('http');
local json = require('json');
local querystring = require('querystring');

HCL.Webhooks = {
	Hooks = {};
	jsonContentData = 'application/json';
	querystringContentData = 'application/x-www-form-urlencoded';
	useJSONByDefault = false; -- Overrides the default content type to use on fireWebhook
};
HCL.Webhooks.Hooks = {};
print('HexCordLib Webhooks | Setting up');

function HCL.Webhooks:isValid(whName)
	whName = whName:lower();
	for i,hookTbl in ipairs(HCL.Webhooks.Hooks) do
		if (hookTbl[1] == whName) then
			return true,hookTbl;
		end;
	end;
	return false;
end;

function HCL.Webhooks:addWebhook(whName,whHookID,whToken)
	whName = whName:lower();
	if HCL.Webhooks:isValid(whName) then
		table.insert(HCL.Webhooks.Hooks,#HCL.Webhooks.Hooks+1,{whName,whHookID,whToken});
		print('HexCordLib Webhooks | Created webhook '..whName..', ID '..whHookID..', and Token '..whToken);
	else
		print('HexCordLib Webhooks | Webhook '..whName..' already exists');
	end;
	print('HexCordLib Webhooks | addWebhook called with Name '..whName..', ID '..whHookID..', and Token '..whToken);
end;

function HCL.Webhooks:removeWebhook(whName)
	whName = whName:lower();
	local target = nil;
	for i,hookTbl in ipairs(HCL.Webhooks.Hooks) do
		if (hookTbl[1] == whName) then
			i = target;
		end;
	end;
	if i ~= nil then 
		table.remove(HCL.Webhooks.Hooks,i);
		print('HexCordLib Webhooks | Successfully removed webhook '..whName);
	else
		print('HexCordLib Webhooks | Webhook '..whName..' not found, can not remove');
	end;
end;

HCL.webhooksFired = 0;

function HCL.Webhooks:sendMessage(whName,msg,texttospeech)
	if type(whName) ~= 'string' or type(msg) ~= 'string' then return nil; end;
	if type(texttospeech) ~= 'boolean' then texttospeech = false; end;
	whName = whName:lower();
	-- At this point the args should be right
	HCL.webhooksFired = HCL.webhooksFired+1;
	local ourHookNum = HCL.webhooksFired;
	print('HexCordLib Webhooks | Hook_'..ourHookNum..': attempting to fire '..whName);
	local isValid,targetHook = HCL.Webhooks:isValid(whName);
	if isValid then
		if #msg > 2000 then -- if true, perform a scuffed truncation
			msg = msg:sub(1,2000); -- idk dude
			print('HexCordLib Webhooks | Hook_'..ourHookNum..': The Params.content for '..whName..' exceeded 2000 characters, truncated');
		end;
		local Params = {content = msg,tts = texttospeech};
		local postBody = json.stringify(Params);
		local Options = {
			hostname = 'www.discordapp.com',
			port = 443,
			path = tostring('/api/webhooks/'..targetHook[2]..'/'..targetHook[3]),
			method = 'POST',
			headers = {
				['Content-Type'] = HCL.Webhooks.jsonContentData,
				['Content-Length'] = postBody:len()
			}
		};
		local s,m = pcall(function()
			local clientRequest = http.request(Options,function(Response)
				print('HexCordLib Webhooks | Hook_'..ourHookNum..': Request info info:\nStatus: '..Response.statusCode..' ('..Response.statusMessage..')\nHeaders: '..json.stringify(Response.headers));
				Response.on('data',function(Chunk)
					print('HexCordLib Webhooks | Hook_'..ourHookNum..': Body:'..Chunk);
				end);
			end);
			clientRequest.on('error',function(Error)
				print('HexCordLib Webhooks | Hook_'..ourHookNum..': Error with request: '..Error.code..' ('..Error.message..')');
			end);

			clientRequest.write(postBody);
			clientRequest.end();
		end);
		if not (s) then
			print('HexCordLib Webhooks |  Hook_'..ourHookNum..': Error occured:\n'..m);
		end;
	else
		print('HexCordLib Webhooks | The webhook '..whName..' does not exist');
	end;
	return ourHookNum;
end;

-- fireWebhook(webHookName,useJsonEncoding,Params) OR fireWebhook(webHookName,Params)
function HCL.Webhooks:fireWebhook(whName,shouldBeJson,Params)
	if type(whName) ~= 'string' then return nil; end;
	if type(shouldBeJson) == 'table' then 
		Params = shouldBeJson;
		shouldBeJson = HCL.Webhooks.useJSONByDefault;
	end;
	whName = whName:lower();
	-- At this point the args should be right
	HCL.webhooksFired = HCL.webhooksFired+1;
	local ourHookNum = HCL.webhooksFired;
	print('HexCordLib Webhooks | Hook_'..ourHookNum..': attempting to fire '..whName);
	local desired = HCL.Webhooks.jsonContentData;
	if Params.content ~= nil then
		if #Params.content > 2000 then -- if true, perform a scuffed truncation
			Params.content = Params.content:sub(1,2000); -- idk dude
			print('HexCordLib Webhooks | Hook_'..ourHookNum..': The Params.content for '..whName..' exceeded 2000 characters, truncated');
		end;
	end;
	local isValid,targetHook = HCL.Webhooks:isValid(whName);
	if isValid then
		local postBody = nil;
		if shouldBeJson then
			postBody = json.stringify(Params); desired = HCL.Webhooks.jsonContentData;
		else
			postBody = querystring.stringify(Params); desired = HCL.Webhooks.querystringContentData;
		end;
		local Options = {
			hostname = 'www.discordapp.com',
			port = 443,
			path = tostring('/api/webhooks/'..targetHook[2]..'/'..targetHook[3]),
			method = 'POST',
			headers = {
				['Content-Type'] = desired,
				['Content-Length'] = postBody:len()
			}
		};
		local s,m = pcall(function()
			local clientRequest = http.request(Options,function(Response)
				print('HexCordLib Webhooks | Hook_'..ourHookNum..': Request info info:\nStatus: '..Response.statusCode..' ('..Response.statusMessage..')\nHeaders: '..json.stringify(Response.headers));
				Response.on('data',function(Chunk)
					print('HexCordLib Webhooks | Hook_'..ourHookNum..': Body:'..Chunk);
				end);
			end);
			clientRequest.on('error',function(Error)
				print('HexCordLib Webhooks | Hook_'..ourHookNum..': Error with request: '..Error.code..' ('..Error.message..')');
			end);

			clientRequest.write(postBody);
			clientRequest.end();
		end);
		if not (s) then
			print('HexCordLib Webhooks |  Hook_'..ourHookNum..': Error occured:\n'..m);
		end;
	else
		print('HexCordLib Webhooks | The webhook '..whName..' does not exist');
	end;
	return ourHookNum;
end;