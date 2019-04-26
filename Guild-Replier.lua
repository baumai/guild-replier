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

local DEBUG_MODE = false;

function printWhenDebug(text)
  if DEBUG_MODE then
    print("Guild-Replier " .. text);
  end;
end;

local timestampLastReplierMessageUnixSeconds = GetServerTime();
local timestampLastGuildMessageUnixSeconds = GetServerTime();

function loadedMessage()
  print("Guild-Replier loaded (made by Berx-Alexstrasza)");
  printWhenDebug("DEBUG MODE is ON timestampLastReplierMessageUnixSeconds:" .. timestampLastReplierMessageUnixSeconds);
end;

local minimumSecondsBetweenMessagesOrTimer = 60;
if DEBUG_MODE then
    minimumSecondsBetweenMessagesOrTimer = 10;
end;

local secondsCheckForSilence = 300;
if DEBUG_MODE then
    secondsCheckForSilence = 10;
end;

-- TODO so sagt er einmal hi, aber dann niewieder
-- TODO es müsste nach ein paar stunden reseten, aber nur nach einem login/reload etc. ...

function oftenReplier()
  printWhenDebug("oftenReplier()");
  
  local currentUnixSeconds = GetServerTime();
  if (currentUnixSeconds - globalSavedVarLastLoginTimestampSeconds) < 10 then
    sendReplierMessage(getDayTimeBasedGreeting());
  end;
end;
C_Timer.NewTicker(10, oftenReplier);

function writeSomeGossipWhenItIsSilent()
	local currentUnixSeconds = GetServerTime();

    if (currentUnixSeconds-secondsCheckForSilence) > timestampLastGuildMessageUnixSeconds then
		timestampLastGuildMessageUnixSeconds = GetServerTime();
		
		local array_words = {
		  "Und sonst so?", 
		  "Mit dem Fahrrad ist schneller, als über den Berg ^^", 
		  "Hier könnte man noch viele Texte ergänzen..."}
		local answer = array_words[math.random(table.getn(array_words))];
		
		-- TODO more texts needed for activation
		-- sendReplierMessage(answer);
	end;
end;
C_Timer.NewTicker(minimumSecondsBetweenMessagesOrTimer, writeSomeGossipWhenItIsSilent);

local frame0=CreateFrame("Frame");
frame0:RegisterEvent("CHAT_MSG_GUILD");
frame0:RegisterEvent("CHAT_MSG_SYSTEM");
frame0:RegisterEvent("PLAYER_LOGIN");
if DEBUG_MODE then
    frame0:RegisterEvent("CHAT_MSG_SAY");
end;
frame0:SetScript("OnEvent",function(self,event,msg,byWhomName, arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11, byWhomGUID)

    local myGUID = UnitGUID("player");
    if (event=="CHAT_MSG_GUILD" or (DEBUG_MODE and event=="CHAT_MSG_SAY")) then
		timestampLastGuildMessageUnixSeconds = GetServerTime();
    end;
    if (event=="CHAT_MSG_GUILD" and myGUID ~= byWhomGUID) or (DEBUG_MODE and event=="CHAT_MSG_SAY") then
        printWhenDebug("first event block");

        byWhomName, realmName = strsplit("-", byWhomName);

        if msg=="hi" or msg=="moin" or msg=="hallo" or msg=="tach" then
        elseif msg=="re" or msg=="wieder da" then
		    --TODO
            -- sagen auch viele anderen gegenueber, ware jetzt online ist da besser
            -- printGuildMessage(byWhomName, "welcome");
            printGuildMessage(byWhomName, "returned");
        elseif msg=="bb" or msg=="gn8" or msg=="bin weg" or msg=="bis dann" or msg=="bis später" then
            printGuildMessage(byWhomName, "going");
        end;
    end;

    if event=="CHAT_MSG_SYSTEM" or (DEBUG_MODE and event=="CHAT_MSG_SAY") then
        printWhenDebug("second event block msg:" .. msg .. ":");

        if string.find(msg, "ist jetzt online") then
            msg = strsplit("]", msg);
            dummy, msg = strsplit("[", msg);
            byWhomName, realmName = strsplit("-", msg);
            printGuildMessage(byWhomName, "welcome");
        end;
    end;

    if event=="PLAYER_LOGIN" then
        printWhenDebug("PLAYER_LOGIN");
	    local currentUnixSeconds = GetServerTime();

        if globalSavedVarLastLoginTimestampSeconds == nil then
		  printWhenDebug("YES update globalSavedVarLastLoginTimestampSeconds");
		  globalSavedVarLastLoginTimestampSeconds = GetServerTime();
		else
		  printWhenDebug("DONT update globalSavedVarLastLoginTimestampSeconds");
		  if (currentUnixSeconds - globalSavedVarLastLoginTimestampSeconds) > 3*60*60 then
		    printWhenDebug("YES update, cause older than three hours, globalSavedVarLastLoginTimestampSeconds");
		    globalSavedVarLastLoginTimestampSeconds = currentUnixSeconds;
		  end;
		end;
    end;
end);

function getDayTimeBasedGreeting()
	local numericCurrentHour = tonumber(date("%H", GetServerTime()));
    if numericCurrentHour > 5 and numericCurrentHour <= 10 then
		return "moin";
	elseif numericCurrentHour > 10 and numericCurrentHour < 13 then
		return "mahlzeit";
	elseif numericCurrentHour > 17 and numericCurrentHour < 22 then
		return "nabend";
	else
		local array_words = {"hoi", "hey", "tach", "servus", "grüße", "hi", "hallo"}
		return array_words[math.random(table.getn(array_words))];
	end;
end;

function printGuildMessage(byWhom, actionStr)
    printWhenDebug("printGuildMessage  byWhom:"..byWhom..":  actionStr:"..actionStr..":");

    if actionStr == "welcome" then
		answer = getDayTimeBasedGreeting() .. " " .. byWhom;
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

    local currentUnixSeconds = GetServerTime();

    if (currentUnixSeconds-minimumSecondsBetweenMessagesOrTimer) > timestampLastReplierMessageUnixSeconds then
        timestampLastReplierMessageUnixSeconds = GetServerTime();
        sendReplierMessage(answer);
    elseif DEBUG_MODE then
        sendReplierMessage(answer .. "  debug normally nothing said cause of time");
    end;
end;

function sendReplierMessage(text)
	if DEBUG_MODE then
        SendChatMessage(text .. "  debug", "SAY");
    else
		SendChatMessage(text, "GUILD");
    end;
end;
