--[[

tfm.exec.addImage
tfm.exec.removeImage
ui.addPopup
ui.addTextArea
ui.removeTextArea
ui.setBackgroundColor
ui.setMapName
ui.setShamanName
ui.showColorPicker
ui.updateTextArea

]]



function Ui.Object:new(id)
    local this = setmetatable({
        id = id,
        elements = {},
        renderPosition = {},
        counter = {
            ColorPicker = 0,
            TextArea = 0,
            Image = 0,
            Popup = 0
        }
    }, self)
end

function Ui.Object:copyFrom(parent)
    self.elements = parent.elements
    self.renderPosition = parent.renderPosition
    self.counter = parent.counter
end

do
    local assert = assert
    local type = type
    local next = next
    function Ui.Object:forElements(f)
        assert(type(f) == "function", "Ui.Object:forElements 'f' argument must be a function.")
        
        for identifier, element in next, self.elements do
            f(identifier, element)
        end
    end
end

do
    local remove = table.remove
    local ipairs = ipairs
    local assert = assert
    local type = type
    function Ui.Object:removeElement(identifier)
        local candidate = self.elements[identifier]
        
        if candidate then
            remove(self.renderPosition, candidate.renderId)
            
            local key, element
            for i = candidate.renderId, #self.renderPosition do
                key = self.renderPosition[i]
                element = self.elements[key]
                
                
                element.renderId = i
                if element.type == candidate.type then
                    self.counter[element.type] = self.counter[element.type] - 1
                    if element.type ~= "Image" then
                        element.presenceId = element.presenceId - 1
                    end
                end
            end
        end
        
        self.elements[identifier] = nil
        
        return self
    end
    
    function Ui.Object:newElement(_type, identifier, properties)
        local uniqueIndex = ("%s-%s"):format(_type, tostring(identifier))
        
        self:removeElement(uniqueIndex)
        
        local index = #self.renderPosition + 1
        
        local presenceId = -1
        if _type ~= "Image" then
            presenceId = self.counter[_type] + 1
            self.counter[_type] = presenceId
        end
        
        self.elements[uniqueIndex] = {
            type = _type,
            properties = properties,
            renderId = index,
            presenceId = presenceId
        }
        
        self.renderPosition[index] = uniqueIndex
        
        return self, index
    end
    
    function Ui.Object:addTextArea(identifier, text, xPosition, yPosition, width, height, backgroundColor, borderColor, backgroundAlpha, fixedPos, anchorX, anchorY)
        self:newElement("TextArea", identifier, {
            text = text or "",
            xPosition = xPosition or 50,
            yPosition = yPosition or 50,
            width = width or 0,
            height = height or 0,
            backgroundColor = backgroundColor or 0x324650,
            borderColor = borderColor or 0x010101,
            backgroundAlpha = backgroundAlpha or 1.0,
            fixedPos = fixedPos or false,
            anchorX = anchorX or 0,
            anchorY = anchorY or 0
        })
        
        return self
    end
    
    function Ui.Object:addImage(identifier, imageUrl, targetLayer, xPosition, yPosition, scaleX, scaleY, rotation, alpha, anchorX, anchorY, fadeIn, fadeOut)
        self:newElement("Image", identifier, {
            imageUrl = imageUrl or "149a49e4b38.jpg",
            targetLayer = targetLayer or ":1",
            xPosition = xPosition or 0,
            yPosition = yPosition or 0,
            scaleX = scaleX or 1.0,
            scaleY = scaleY or 1.0,
            rotation = rotation or 0.0,
            alpha = alpha or 1.0,
            anchorX = anchorX or 0.0,
            anchorY = anchorY or 0.0,
            fadeIn = fadeIn or false,
            fadeOut = fadeOut or false
        })
    
        return self
    end
    
    function Ui.Object:addPopup(identifier, type, text, targetPlayer, xPosition, yPosition, width, fixedPos, anchorX)        
        self:newElement("Popup", identifier, {
            type = type or 0,
            text = text or "",
            xPosition = xPosition or 50,
            yPosition = yPosition or 50,
            width = width,
            fixedPos = fixedPos or false,
            anchorX = anchorX or 0.0
        })
        
        return self
    end
    
    function Ui.Object:addColorPicker(identifier, defaultColor, title)
        assert(type(identifier) == "number", "Ui.Object:addColorPicker argument 'identifier' must be a Number.")
        
        self:newElement("ColorPicker", identifier, {
            defaultColor = defaultColor or 0x010101,
            title = title or ""
        })
        
        return self
    end
end

function Ui.Object:setElement(elementId, propertyId, value)
    local element = self.elements[elementId]
    
    if element then
       element[propertyId] = value 
    end
    
    return self
end

do
    local addTextArea = ui.addTextArea
    local addImage = tfm.exec.addImage
    local addPopup = ui.addPopup
    local addColorPicker = ui.showColorPicker
    
    local render = {
        Image = function(e, target)
            local p = e.properties
            e.presenceId = addImage(
                p.imageUrl, p.targetLayer,
                p.xPosition, p.yPosition,
                target,
                p.scaleX, p.scaleY,
                p.rotation, p.alpha,
                p.anchorX, p.anchorY,
                p.fadeIn
            )
        end,
        TextArea = function(e, target)
            local p = e.properties
            addTextArea(
                e.presenceId,
                e.text,
                target,
                p.xPosition - (p.width * p.anchorX),
                p.yPosition - (p.height * p.anchorY),
                p.width, p.height,
                p.backgroundColor,
                p.borderColor,
                p.backgroundAlpha,
                p.fixedPos
            )
        end,
        Popup = function(e, target)
            local p = e.properties
            addPopup(
                e.presenceId,
                p.type,
                p.text,
                target,
                p.xPosition - (p.width * p.anchorX),
                p.yPosition,
                p.width,
                p.fixedPos
            )
        end,
        ColorPicker = function(e, target)
            local p = e.properties
            
            addColorPicker(e.presenceId, target, p.defaultColor, p.title)
        end
    }
    
    function Ui.Object:renderElement(elementId, targetPlayer)
        local element = self.elements[elementId]
        
        if element then
            render[element.type](element, targetPlayer)
        end
        
        return self
    end
    
    function Ui.Object:render(targetPlayer)
        for position, elementId in ipairs(self.renderPosition) do
            self:renderElement(elementId, targetPlayer)
        end
        
        return self
    end
    
    local removeImage = tfm.exec.removeImage
    local removeTextArea = ui.removeTextArea
    
    local hide = {
        Image = function(e)
            removeImage(e.presenceId, e.properties.fadeOut)
        end,
        TextArea = function(e, target)
            removeTextArea(e.presenceId, target)
        end,
        Popup = function(e, target)
            addPopup(e.presenceId, 0, "", target, 400, 500, 50, true)
        end,
        ColorPicker = function()
            
        end
    }
    
    function Ui.Object:hideElement(elementId, targetPlayer)
        local element = self.elements[elementId]
        
        if element then
            hide[element.type](element, targetPlayer)
        end
        
        return self
    end
    
    function Ui.Object:hide(targetPlayer)
        for position, elementId in ipairs(self.renderPosition) do
            self:hideElement(elementId, targetPlayer)
        end
        
        return self
    end
    
    function Ui.Object:refreshElement(elementId, targetPlayer)
        self:hideElement(elementId, targetPlayer)
        self:renderElement(elementId, targetPlayer)
        
        return self
    end
    
    function Ui.Object:refresh(targetPlayer)
        self:hide(targetPlayer)
        self:render(targetPlayer)
        
        return self
    end
end