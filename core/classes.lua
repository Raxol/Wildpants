--[[
	classes.lua
		Utility method for constructing object classes and messaging between them
--]]

local ADDON, Addon = ...
local Mixins = {'RegisterEvent', 'UnregisterEvent', 'UnregisterEvents', 'RegisterMessage', 'UnregisterMessage', 'UnregisterMessages', 'SendMessage'}
local Messages = {}


--[[ Libraries ]]--

LibStub('AceAddon-3.0'):NewAddon(Addon, ADDON, 'AceEvent-3.0')
Addon.SendMessage = LibStub('CallbackHandler-1.0'):New(Messages, 'RegisterMessage', 'UnregisterMessage', 'UnregisterMessages').Fire
Addon.Cache = LibStub('LibItemCache-1.1')
_G[ADDON] = Addon

for key, func in pairs(Messages) do
	Addon[key] = func
end


--[[ API ]]--

function Addon:NewClass(name, type, parent)
	local class = CreateFrame(type or 'Frame')
	class.__index = class
	class.Name = name
  class:Hide()

	if parent then
		class = setmetatable(class, parent)
		class.__super = parent
	else
		class.Bind = function(self, obj)
			return setmetatable(obj, self)
		end

		class.RegisterFrameMessage = function(self, msg, ...)
			self:RegisterMessage(self:GetFrameID() .. msg, ...)
		end

		class.UnregisterFrameMessage = function(self, msg, ...)
			self:UnregisterMessage(self:GetFrameID() .. msg, ...)
		end

		class.SendFrameMessage = function(self, msg, ...)
			self:SendMessage(self:GetFrameID() .. msg, ...)
		end

		class.GetFrameID = function(self)
			local frame = self:GetFrame()
			return frame and frame.frameID
		end

		class.GetProfile = function(self)
			local frame = self:GetFrame()
			return frame and frame:GetProfile()
		end

		class.GetPlayer = function(self)
			local frame = self:GetFrame()
			return frame and frame:GetPlayer()
		end

		class.IsCached = function(self)
			local frame = self:GetFrame()
			return frame and frame:IsCached()
		end

		class.GetFrame = function(self)
			if not self.frame then -- loop of doom, do only once
				local parent = self:GetParent()
				while parent and not parent.frameID do
					parent = parent:GetParent()
				end

				self.frame = parent
			end
			return self.frame
		end

		for i, func in ipairs(Mixins) do
			class[func] = self[func]
		end
	end

	self[name] = class
	return class
end

function Addon:UnregisterEvents()
	Addon.UnregisterAllEvents(self)
	Addon.UnregisterMessages(self)
end
