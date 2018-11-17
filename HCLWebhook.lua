--[[ Discord Wehhook sub-library, by Kobal
	
	This is based off a Node.js module that does the same thing but it simply only sends messages to 1 hook
	This was originally its own thing
	Expect tons of errors attemptig to use this
	
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
local http = require('http');
local json = require('json');
local querystring = require('querystring');
HCL.Webhooks = {
	Hooks = {};
	baseSite = "www.discordapp.com";
	webhookPath = "/api/webhooks";
	jsonContentData = 'application/json';
	querystringContentData = 'application/x-www-form-urlencoded';
	defaultPort = 443;
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

function HCL.Webhooks:sendMessage(whName,msg,texttospeech)
	whName = whName:lower();
	if ((type(whName) ~= 'string') or (type(msg) ~= 'string')) then return nil; end;
	if (type(texttospeech) ~= 'boolean') then texttospeech = false; end;
	
	local isValid,targetHook = HCL.Webhooks:isValid(whName);
	if isValid then
		local Params = {content = msg,tts = texttospeech};
		local postBody = json.stringify(Params);
		
		local Options = {
			hostname = HCL.Webhooks.baseSite,
			port = HCL.Webhooks.defaultPort,
			path = tostring(HCL.Webhooks.webhookPath..'/'..targetHook[2]..'/'..targetHook[3]),
			method = 'POST',
			headers = {
				['Content-Type'] = HCL.Webhooks.jsonContentData,
				['Content-Length'] = postBody:len()
			}
		};
		
		local s,m = pcall(function()
			local clientRequest = http.request(Options,function(response)
				print(type(response));
				print(response);
			end);
			clientRequest:done();
		end);
		
		if not (s) then
			print('HexCordLib Webhooks | Error occured:\n'..m);
		end;
	else
		print('HexCordLib Webhooks | The webhook '..whName..' does not exist');
	end;
end;

function HCL.Webhooks:fireWebhook(whName,contenttype,content)
	whName = whName:lower();
	if ((type(whName) ~= 'string') or (type(contenttype) ~= 'string') or (type(content) ~= 'table')) then return end;
	contenttype = contenttype:lower();
	local cType = 'j'; local desired = HCL.Webhooks.jsonContentData;
	if (contenttype == 'json') or (contenttype == 'j') then
		cType = 'j'; desired = HCL.Webhooks.jsonContentData;
	elseif (contenttype == 'querystring') or (contenttype == 'q') then
		cType = 'q'; desired = HCL.Webhooks.querystringContentData;
	end;
	
	local isValid,targetHook = HCL.Webhooks:isValid(whName);
	if isValid then
		local Params = content;
		local postBody = nil;
		if (cType == 'j') then
			postBody = json.stringify(Params);
		else
			postBody = querystring.stringify(Params);
		end;
		
		local Options = {
			hostname = HCL.Webhooks.baseSite,
			port = HCL.Webhooks.defaultPort,
			path = tostring(HCL.Webhooks.webhookPath..'/'..targetHook[2]..'/'..targetHook[3]),
			method = 'POST',
			headers = {
				['Content-Type'] = desired,
				['Content-Length'] = postBody:len()
			}
		};
		
		local s,m = pcall(function()
			local clientRequest = http.request(Options,function(response)
				print(type(response));
				print(response);
			end);
			clientRequest:done();
		end);
		
		if not (s) then
			print('HexCordLib Webhooks | Error occured:\n'..m);
		end;
	else
		print('HexCordLib Webhooks | The webhook '..whName..' does not exist');
	end;
end;