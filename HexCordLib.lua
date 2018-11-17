--[[
	 _    _            _____              _ _      _ _
	| |  | |          / ____|            | | |    (_) |
	| |__| | _____  _| |     ___  _ __ __| | |     _| |__
	|  __  |/ _ \ \/ / |    / _ \| '__/ _` | |    | | '_ \
	| |  | |  __/>  <| |___| (_) | | | (_| | |____| | |_) |
	|_|  |_|\___/_/\_\\_____\___/|_|  \__,_|______|_|_.__/
	
	HexCordLib, a Discordia lua helper library
	
	Working on this along side KobalLib, a GMod lua helper library
]]--
print('HexCordLib | Init main module');
local HCL = {}:
local Discordia = require('discordia');
HCL.Version = '0.0.2-prerelease';
HCL.ourClient = nil;
HCL.ourUser = nil;
HCL.ourClientOptions = nil; -- Optional I guess

print('HexCordLib | Loading helper modules');
require('./HCLUtils');
require('./HCLWebhook');

-- I plan to replace this table with enums and make the permission functions use the enumerations instead
-- Currently in progress, this may be for reference only
HCL.Permissions = { -- name, hexadecimal
	{'createInstantInvite',0x00000001},
	{'kickMembers',0x00000002},
	{'banMembers',0x00000004},
	{'administrator',0x00000008},
	{'manageChannels',0x00000010},
	{'manageGuild',0x00000020},
	{'addReactions',0x00000040},
	{'viewAuditLog',0x00000080}
	{'readMessages',0x00000400},
	{'sendMessages',0x00000800},
	{'sendTextToSpeech',0x00001000},
	{'manageMessages',0x00002000},
	{'embedLinks',0x00004000},
	{'attachFiles',0x00008000},
	{'readMessageHistory',0x00010000},
	{'mentionEveryone',0x00020000},
	{'useExternalEmojis',0x00040000},
	{'connect',0x00100000},
	{'speak',0x00200000},
	{'muteMembers',0x00400000},
	{'deafenMembers',0x00800000},
	{'moveMembers',0x01000000},
	{'useVoiceActivity',0x02000000},
	{'changeNickname',0x04000000},
	{'manageNicknames',0x08000000},
	{'manageRoles',0x10000000},
	{'manageWebhooks',0x20000000},
	{'manageEmojis',0x40000000}
};

-- idk for my own use
HCL.quickEmoji = {
	error1 = ':no_entry_sign:', error2 = ':x:', mod = ':shield:', leavebot = ':wave:',
	warning = ':warning:', join = ':arrowup:', leave = ':arrowdown:', leaveforced1 = ':boot:',leaveforced2 = ':skull:'
	positive = ':white_check_mark:', negative = ':negative_squared_cross_mark:',
	errorweeb = ':anger:', gear = ':gear:', pingcheck = ':signal_strength:'
};

HCL.eightBallQuotes = {'It is certain','It is decidedly so','Without a doubt','Yes definitely',' You may rely on it',
	'As I see it, yes','Most likely','Outlook good','Yes','Signs point to yes','Reply hazy try again',
	'Ask again later','Better not tell you now','Cannot predict now','Concentrate and ask again',
	"Don't count on it",'My reply is no','My sources say no','Outlook not so good','Very doubtful'
};

function HCL:ask8Ball(arg)
	if (arg:match('%?$') == '?') then -- Checks if the arg is an actual question
		return true,eightBallQuotes[math.random(1,#eightBallQuotes)]; -- Is an actual question, get a random 8ball message
	else
		return false; -- Not a question, return false to say that the arg isn't a real question
	end;
end;

function HCL:QUICKMAFFS()
	return (2+2)-3; -- quickie
end;

function HCL:memberHasPermission(member,perm)
	local exists = false;
	if type(perm) == 'number' then
		if type(Discordia.enums.permissions(perm)) == 'string' then
			exists = true;
		end;
	elseif type(perm) == 'string' then
		if type(Discordia.enums.permissions[perm]) == 'number' then
			exists = true;
		end;
	end;
	if (exists == false) then
		print('While checking perms on member '..member.username..'#'..member.discriminator..', the bot tried to look for an invalid permission called '..tostring(perm)..'\nTraceback: '..debug.traceback());
		return false;
	end;
	if (member.id == member.guild.owner.id) then return true; end;
	for i,role in member.roles do
		if ((role.permissions:has(Discordia.enums.permissions.administrator)) or (role.permissions:has(perm))) then
			return true;
		end;
	end;
	return false;
end;

function HCL:seperateNameAndDiscriminator(combined)
	local firstsub,lastsub,discrim = combined.find('#%d%d%d%d$');
	local name = nil;
	name = combined:sub(1,firstsub-1);
	return name,discrim;
end;

function HCL:findMemberAndUserBySnowflake(guild,snowflake)
	for i,member in guild.members do
		if (member.user.id == snowflake) then
			return member,member.user;
		end;
	end;
	return nil;
end;

return HCL;