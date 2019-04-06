--[[
Guild-Replier - automatic, time-based world of warcraft guild-chat-replier
Copyright (C) 2019 Berx-Alexstrasza (world of warcraft character of the author)

This file is part of Guild-Replier.

Guild-Replier is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Guild-Replier is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with Guild-Replier. If not, see <http://www.gnu.org/licenses/>.
]]

function loadedMessage() 
  print("Guild-Replier loaded (made by Berx-Alexstrasza)");
end;

local frame0=CreateFrame("Frame");
frame0:RegisterEvent("CHAT_MSG_GUILD");
frame0:RegisterEvent("CHAT_MSG_SYSTEM");
frame0:SetScript("OnEvent",function(self,event,msg,byWhomName, arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11, byWhomGUID)	
	
	local myGUID = UnitGUID("player");
	if event=="CHAT_MSG_GUILD" and myGUID ~= byWhomGUID then
	
		byWhomName, realmName = strsplit("-", byWhomName);
	
		if msg=="hi" or msg=="moin" or msg=="hallo" or msg=="tach" then
			-- printGuildMessage(byWhomName, "welcome");
		end;
		if msg=="re" or msg=="wieder da" then
			printGuildMessage(byWhomName, "returned");
		end;
		if msg=="bb" or msg=="gn8" or msg=="bin weg" or msg=="bis dann" or msg=="bis später" then
			printGuildMessage(byWhomName, "going");
		end;
	end;
	
	if event=="CHAT_MSG_SYSTEM" then	
		if string.find(msg, "ist jetzt online") then
			msg = strsplit("]", msg);
			dummy, msg = strsplit("[", msg);
			byWhomName, realmName = strsplit("-", msg);
			printGuildMessage(byWhomName, "welcome");
		end;
	end;
	
end);

function printGuildMessage(byWhom, actionStr)

	local numericCurrentHour = tonumber(date("%H", GetServerTime()));
	-- local suffix = "   (auto, gettin' better and better)";
	local suffix = "    (iA)";
	
	--default
	-- TODO default answers hi, huhu, hallo, etc.
	-- hoi x  hey x   tach x  servus x grüße x
	-- "hoi","hey","tach","servus","grüße","hi","hallo"
	local array_words = {"hoi", "hey", "tach", "servus", "grüße", "hi", "hallo"}
	local answer = array_words[math.random(7)] .. " " .. byWhom;
	
	if actionStr == "welcome" then
		if numericCurrentHour > 5 and numericCurrentHour < 10 then
			answer = "moin " .. byWhom;
		end;
		if numericCurrentHour > 10 and numericCurrentHour < 13 then
			answer = "mahlzeit " .. byWhom;
		end;
		if numericCurrentHour > 17 and numericCurrentHour < 22 then
			answer = "nabend " .. byWhom;
		end;
	end;
	
	if actionStr == "returned" then
		answer = "wb " .. byWhom;
	end;
	
	if actionStr == "going" then
	
		-- default
		answer = "bis dann " .. byWhom;
		
		if numericCurrentHour > 19 and numericCurrentHour < 3 then
			answer = "Gute Nacht " .. byWhom .. "!";
		end;
	end;
	
	SendChatMessage(answer .. suffix, "GUILD");
	
end;
