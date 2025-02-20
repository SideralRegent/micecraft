if false then
	local IComp = {}
	IComp.__index = IComp
	
	local resList = {
		-- so when we do smth:append I do not have to give it ugly format each time
		__index = {
			append = function(self, type, identifier, ...)
				self[#self + 1] = {
					id = identifier, 
					type = type,
					args = {...}
				}
			end
		}
	}
	
	local IType_image = 0
	local IType_text = 1
	local IType_textid = 10
	local IType_popup = 2
	local IType_comp = 3
	
	-- Copies the contents of fset from its parent
	local t_copy_fset = function(parent)
		local fset = {}
		
		for i, settler in next, parent.fset do
			fset[i] = settler
		end
		
		return fset
	end
	
	
	
	--- Creates a new **I**nterface **Comp**osition object.
	--- d
	-- @name IComp:
	-- @param t:n d
	-- @return `t` d
	function IComp:new(uniqueId)
		local this = setmetatable({
			uniqueId = uniqueId,
			stack = setmetatable({}, resList),
			kmap = {}, --setmetatable({}, resList),
			fset = t_copy_fset(self),
		}, self)

		this.__index = this

		return this
	end
	
	local tfm_exec_removeImage = tfm.exec.removeImage
	local ui_removeTextArea = ui.removeTextArea
	--- Defines the methods to remove this object from view.
	-- @name remove_method
	-- @param Int:id Object identifier.
	-- @param Table:F The list of args given originally.
	local remove_method = {
		[IType_image] = function(id, F)
			tfm_exec_removeImage(id, false)
		end,
		[IType_text] = function(id, F)
			ui_removeTextArea(id, F[2])
		end,
		[IType_textid] = function(id, F)
			ui_removeTextArea(id, F[3])
		end,
		[IType_popup] = function(id, args) end,
		[IType_comp] = function(id, F)
			id:destroy() -- F[1] and id are the same
		end,
	}
	
	--- Destroys a composition object.
	-- It basically deletes all its stack and references. This is a destructive 
	-- operation, object is left unusable after destroying.
	-- @name IComp:destroy
	function IComp:destroy()
		local T -- «target»
		for i = #self.stack, -1, 1 do
			T = self.stack[i]
			remove_method[T.type](T.id, T.args)
		end
		
		self.stack = nil
		self.kmap = nil
	end
	
	local tfm_exec_addImage = tfm.exec.addImage
	local ui_ciaddTextArea = ui.ciaddTextArea
	local ui_caddTextArea = ui.caddTextArea
	
	--- Defines methods to render each type of object.
	-- @name render_method
	-- @param Table:F List of arguments for rendering.
	-- @return `Int|Table` Identifier or object itself (child comp case).
	local render_method = {
		[IType_image] = function(F)
			return tfm_exec_addImage(F[1], F[2], F[3], F[4], F[5], F[6], F[7], F[8], F[9], F[10], F[11], F[12])
		end,
		[IType_text] = function(F)
			return ui_ciaddTextArea(F[1], F[2], F[3], F[4], F[5], F[6], F[7], F[8], F[9], F[10], F[11], F[12])
		end,
		[IType_textid] = function(F)
			ui_caddTextArea(F[0], F[1], F[2], F[3], F[4], F[5], F[6], F[7], F[8], F[9], F[10], F[11], F[12])
			return F[0]
		end,
		[IType_comp] = function(F)
			F[0]:render()
			return F[0]
		end,
		[IType_popup] = function(F)
			return 0--return ui.addPopup(
		end
	}
	
	--- Builds a Text Area which also accepts alignment values.
	-- @name IComp:setIText
	-- @param Int:id Identifier.
	-- @param Any:... Extra arguments.
	-- @return `self` 
	function IComp:setIText(id, ...)
		self.stack:append(IType_textid, id, ...)
		
		return self
	end
	
	--- See IComp:setItext. Accepts an alias.
	-- @name IComp:kSetIText
	-- @param Any:alias Alternative name for this field, useful for IComp:updateElement
	-- @param Any:... Extra arguments.
	-- @return `self`
	function IComp:kSetIText(alias, ...)
		self:setIText(...)
		self.kmap[alias] = #self.stack
		
		return self
	end
	
	--- Builds a Text Area which also accepts alignment values.
	-- Id is generated automatically.
	-- @name IComp:setText
	-- @param Any:... Extra arguments.
	-- @return `self` 
	function IComp:setText(...)
		self.stack:append(IType_text, 0, ...)
		
		return self
	end
	--- See IComp:setText. Accepts an alias.
	-- @name IComp:kSetText
	-- @param Any:alias Alternative name for this field, useful for IComp:updateElement
	-- @param Any:... Extra arguments.
	-- @return `self`
	function IComp:kSetText(alias, ...)
		self:setText(...)
		self.kmap[alias] = #self.stack
		
		return self
	end
	
	--- Builds an image.
	-- @name IComp:setImage
	-- @param Any:... Extra arguments.
	-- @return `self` 
	function IComp:setImage(...)
		self.stack:append(IType_image, 0, ...)
		
		return self
	end
	--- See IComp:setImage. Accepts an alias.
	-- @name IComp:kSetImage
	-- @param Any:alias Alternative name for this field, useful for IComp:updateElement
	-- @param Any:... Extra arguments.
	-- @return `self`
	function IComp:kSetImage(alias, ...)
		self:setImage(...)
		self.kmap[alias] = #self.stack
		
		return self
	end
	
	--- Stores another Composition.
	-- @name IComp:setComp
	-- @param Comp:comp A composition object itself.
	-- @param Any:... Extra arguments.
	-- @return `self` 
	function IComp:setComp(comp, ...)
		self.stack:append(IType_comp, comp, ...)
		
		return self
	end
	--- See IComp:setComp. Accepts an alias.
	-- @name IComp:kSetComp
	-- @param Any:alias Alternative name for this field, useful for IComp:updateElement
	-- @param Any:... Extra arguments.
	-- @return `self`
	function IComp:kSetComp(alias, ...)
		self:setComp(...)
		self.kmap[alias] = #self.stack
		
		return self
	end
	
	--- Renders this composition (shows everything)
	-- @name IComp:render
	-- @return `Int` The unique identifier of this object in the interface.
	function IComp:render()
		for _, element in next, self.stack do
			element.id = render_method[element.type](element.args)
		end
		
		return self.uniqueId
	end
	
	
	
	local t_xor = function(a, b)
		return {
			a[1] or b[1],
			a[2] or b[2],
			a[3] or b[3],
			a[4] or b[4],
			a[5] or b[5],
			a[6] or b[6],
			a[7] or b[7],
			a[8] or b[8],
			a[9] or b[9],
			a[10] or b[10],
			a[11] or b[11],
			a[12] or b[12],
			a[13] or b[13],
			a[14] or b[14],
		}
	end
	
	local mrender_preset = {
		playerName = function(name)
			return {
				[IType_image] = {nil, nil, nil, nil, name},
				[IType_comp] = {name},
				[IType_text] = {nil, name},
				[IType_textid] = {nil, nil, name},
				[IType_popup] = {nil, nil, name},
			}
		end
	}
	--- Same as IComp:render. You can dinamically modify/overwrite some fields,
	--  based on the type of interface.
	-- This is useful for interfaces that are common to every player, but
	-- only need their 'playerName' field to be modified.
	-- The 'playerName' preset will replace only playerName correspoding fields.
	-- @name IComp:mRender
	-- @param Table|String:argmap A map that replaces arguments.
	-- @param Any:... Extra arguments for the argmap (presets' case).
	-- @return `Int` The unique identifier of this object in the interface.
	function IComp:mRender(argmap, ...)
		local r_set = argmap or mrender_preset[argmap](...)
		for _, element in next, self.stack do
			element.id = render_method[element.type](t_xor(element.args, r_set))
		end
		
		return self.uniqueId
	end
	
	--- Adds elements, based on the settler functions stored.
	-- @name IComp:set
	-- @param Any:... Arguments for the settler functions.
	-- @return `self`
	function IComp:set(...)
		for _, settler in next, self.fset do
			settler(self, ...)
		end
		
		return self
	end
	
	--- Throws away all elements from the stack but keeps the table.
	-- @name IComp:flush
	function IComp:flush()
		for i = 1, #self.stack do
			self.stack[i] = nil
		end
		
		self.kmap = nil
		self.kmap = {}
	end
	
	--- Recalculates all the objects from this composition.
	-- This is just an interface that calls flush then set.
	-- @name IComp:reload
	-- @param Any:... Arguments for IComp:set.
	function IComp:reload(...)
		self:flush()
		self:set(...)
	end
	
	--- Adds a settler function.
	-- The expected format is `nil <- foo(IComp, ...)`.
	-- @name IComp:addSettler
	-- @param Function:settler A function that when called, adds elements.
	-- @return `self`
	function IComp:addSettler(settler)
		self.fset[#self.fset + 1] = settler
		
		return self
	end
	
	--- Returns a (new) valid key for the Interface to assign to this composition.
	-- @name Interface:getValidKey
	-- @param Any:key Key (for checking)
	-- @return `Any|Int` A key to store the composition
	function Interface:getValidKey(key)
		return key or (#self.register + 1)
	end
	
	--- Creates a new, empty composition object.
	-- @name Interface:newCompositon
	-- @param Any:key A key to store this composition
	-- @return `Any|int` The key that stores this composition.
	function Interface:newComposition(key)--, set)
		local comp = IComp:new(-1)
	--	comp:addSettler(set)
		
		key = self:getValidKey()
		self.register[key] = comp
		
		return key
	end
	
	--- d
	-- @name Interface:newFromTemplate
	-- @param t:n d
	-- @return `t` d
	function Interface:newFromTemplate(key, prevk, ...)
		assert(self.register[prevk] or type(prevk) == "table", "Valid template key or value expected.")
		
		local template = self.register[prevk] or prevk
		
		local comp = template:new(-1)
		for _, settler in next, {...} do
			comp:addSettler(settler)
		end
		
		key = self:getValidKey()
		self.register[key] = comp
		
		return key
	end
	
	function Interface:getComposition(key)
		return self.register[key]
	end
	
	function Interface:newInstance(compKey, ...)
		local template = self:getComposition(compKey)
		if template then
			local n_index = #self.stack + 1
			local this = template:new(n_index)
			
			this:set(...)
			
			self.stack[n_index] = this
			
			return self.stack[n_index]
		end
	end
	
	function Interface:removeInstance(id)
		local this = self.stack[id]
		
		if this then
			this:destroy()
		end
		
		self.stack[id] = nil
	end
end -- This is unsuitable for Micecraft

do -- This is suitable.
	function Interface:getIndex()
		return self.settingIndex
	end
	
	function Interface:setIndex(index)
		if index then
			self.settingIndex = index
		else
			self.objAc = self.objAc + 1
			self.settingIndex = self.objAc
		end
		
		return self.settingIndex
	end
	
	local aux = {
		__index = {
			insert = function(t, i, p)
				t[#t + 1] = {id=i, playerName=p}
			end
		}
	}
	
	function Interface:setView(objectId)
		objectId = objectId or self:setIndex(nil)
		
		self.object[objectId] = {
			img = setmetatable({}, aux),
			txt = setmetatable({}, aux),
		}
	end
	
	local removeImage = tfm.exec.removeImage
	local removeTextArea = ui.removeTextArea
	function Interface:removeView(objectId)
		local object = self.object[objectId]
		if not object then return end
		
		local otxt = object.txt
		for i = #otxt, 1, -1 do
			removeTextArea(otxt[i].id, otxt[i].playerName)
		end
		
		local oimg = object.img
		for i = #oimg, 1, -1 do
			removeImage(oimg[i].id, false)
		end
		
		
		self.object[objectId] = nil
		
		return false
	end
	
	function Interface:current()
		return self.object[self.settingIndex]
	end
	
	local iaddTextArea = ui.iaddTextArea
	function Interface:addText(text, targetPlayer, ...)
		local id = iaddTextArea(text, targetPlayer, ...)
		
		self:current().txt:insert(id, targetPlayer)
	end
	
	local ciaddTextArea = ui.ciaddTextArea
	function Interface:caddText(text, targetPlayer, ...)
		local id = ciaddTextArea(text, targetPlayer, ...)
		
		self:current().txt:insert(id, targetPlayer)
	end	
	
	local addTextArea = ui.addTextArea
	function Interface:addIText(id, text, targetPlayer, ...)
		addTextArea(id, text, targetPlayer, ...)
		
		self:current().txt:insert(id, targetPlayer)
	end	
	
	local caddTextArea = ui.caddTextArea
	function Interface:caddIText(id, text, targetPlayer, ...)
		caddTextArea(id, text, targetPlayer, ...)
		
		self:current().txt:insert(id, targetPlayer)
	end
	
	function Interface:updateText(...)
		ui.updateTextArea(...)
	end
	
	local addImage = tfm.exec.addImage
	function Interface:addImage(...)
		local id = addImage(...)
		
		self:current().img:insert(id)
	end	
	
	local ccall = "<a href='event:iclose-%d'>%s</a>"
	function Interface:closeButton(decor, targetPlayer, ...)
		self:caddText(ccall:format(self.settingIndex, decor), targetPlayer, ...)
	end	
	
	function Interface:newComposition(name, definition)
		self[name] = function(...)
			self:setView()
			definition(...)
			return self:getIndex()
		end
	end
end