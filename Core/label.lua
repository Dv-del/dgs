--Dx Functions
local dxDrawText = dxDrawText
local dxGetFontHeight = dxGetFontHeight
local dxGetTextWidth = dxGetTextWidth
--DGS Functions
local dgsSetType = dgsSetType
local dgsGetType = dgsGetType
local dgsSetParent = dgsSetParent
local dgsSetData = dgsSetData
local applyColorAlpha = applyColorAlpha
local dgsTranslate = dgsTranslate
local dgsAttachToTranslation = dgsAttachToTranslation
local dgsAttachToAutoDestroy = dgsAttachToAutoDestroy
local calculateGuiPositionSize = calculateGuiPositionSize
local dgsCreateTextureFromStyle = dgsCreateTextureFromStyle
--Utilities
local triggerEvent = triggerEvent
local createElement = createElement
local assert = assert
local tonumber = tonumber
local type = type

function dgsCreateLabel(x,y,sx,sy,text,relative,parent,textColor,scalex,scaley,shadowoffsetx,shadowoffsety,shadowcolor,right,bottom)
	local xCheck,yCheck,wCheck,hCheck = type (x) == "number",type(y) == "number",type(sx) == "number",type(sy) == "number"
	if not xCheck then assert(false,"Bad argument @dgsCreateLabel at argument 1, expect number got "..type(x)) end
	if not yCheck then assert(false,"Bad argument @dgsCreateLabel at argument 2, expect number got "..type(y)) end
	if not wCheck then assert(false,"Bad argument @dgsCreateLabel at argument 3, expect number got "..type(sx)) end
	if not hCheck then assert(false,"Bad argument @dgsCreateLabel at argument 4, expect number got "..type(sy)) end
	local label = createElement("dgs-dxlabel")
	dgsSetType(label,"dgs-dxlabel")
	dgsSetParent(label,parent,true,true)
	local style = styleSettings.label
	local textSizeX,textSizeY = tonumber(scalex) or style.textSize[1], tonumber(scaley) or style.textSize[2]
	dgsElementData[label] = {
		alignment = {right or "left",bottom or "top"},
		clip = false,
		colorcoded = false,
		font = style.font or systemFont,
		rotation = 0,
		rotationCenter = {0, 0},
		shadow = shadowoffsetx,shadowoffsety,shadowcolor,
		subPixelPositioning = false,
		textColor = textColor or style.textColor,
		textSize = {textSizeX, textSizeY},
		wordbreak = false,
	}
	dgsAttachToTranslation(label,resourceTranslation[sourceResource or getThisResource()])
	if type(text) == "table" then
		dgsElementData[label]._translationText = text
		dgsSetData(label,"text",text)
	else
		dgsSetData(label,"text",tostring(text))
	end
	calculateGuiPositionSize(label,x,y,relative or false,sx,sy,relative or false,true)
	triggerEvent("onDgsCreate",label,sourceResource)
	return label
end

function dgsLabelSetColor(label,r,g,b,a)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetColor at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	if tonumber(r) and g == true then
		return dgsSetData(label,"textColor",r)
	else
		local _r,_g,_b,_a = fromcolor(dgsElementData[label].textColor)
		return dgsSetData(label,"textColor",tocolor(r or _r,g or _g,b or _b,a or _a))
	end
end

function dgsLabelGetColor(label,notSplit)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetColor at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	return notSplit and dgsElementData[label].textColor or fromcolor(dgsElementData[label].textColor)
end

function dgsLabelSetHorizontalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetHorizontalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	assert(HorizontalAlign[align],"Bad argument @dgsLabelSetHorizontalAlign at argument 2, except a string [left/center/right], got"..tostring(align))
	local alignment = dgsElementData[label].alignment
	return dgsSetData(label,"alignment",{align,alignment[2]})
end

function dgsLabelSetVerticalAlign(label,align)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelSetVerticalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	assert(VerticalAlign[align],"Bad argument @dgsLabelSetVerticalAlign at argument 2, except a string [top/center/bottom], got"..tostring(align))
	local alignment = dgsElementData[label].alignment
	return dgsSetData(label,"alignment",{alignment[1],align})
end

function dgsLabelGetHorizontalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetHorizontalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	local alignment = dgsElementData[label].alignment
	return alignment[1]
end

function dgsLabelGetVerticalAlign(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetVerticalAlign at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	local alignment = dgsElementData[label].alignment
	return alignment[2]
end

function dgsLabelGetTextExtent(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetTextExtent at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	local font = dgsElementData[label].font or systemFont
	local textSizeX = dgsElementData[label].textSize[1]
	local text = dgsElementData[label].text
	local colorcoded = dgsElementData[label].colorcoded
	return dxGetTextWidth(text,textSizeX,font,colorcoded)
end

function dgsLabelGetFontHeight(label)
	assert(dgsGetType(label) == "dgs-dxlabel","Bad argument @dgsLabelGetFontHeight at argument 1, except a dgs-dxlabel got "..dgsGetType(label))
	local font = dgsElementData[label].font or systemFont
	local textSizeY = dgsElementData[label].textSize[2]
	return dxGetFontHeight(textSizeY,font)
end

----------------------------------------------------------------
--------------------------Renderer------------------------------
----------------------------------------------------------------
dgsRenderer["dgs-dxlabel"] = function(source,x,y,w,h,mx,my,cx,cy,enabled,eleData,parentAlpha,isPostGUI,rndtgt)
	local alignment = eleData.alignment
	local colors,imgs = eleData.textColor,eleData.image
	colors = applyColorAlpha(colors,parentAlpha)
	local colorimgid = 1
	if MouseData.enter == source then
		colorimgid = 2
		if MouseData.clickl == source then
			colorimgid = 3
		end
	end
	local font = eleData.font or systemFont
	local clip = eleData.clip
	local wordbreak = eleData.wordbreak
	local text = eleData.text
	local txtSizX,txtSizY = eleData.textSize[1],eleData.textSize[2]
	local colorcoded = eleData.colorcoded
	local shadow = eleData.shadow
	local subPixelPos = eleData.subPixelPositioning and true or false
	local rotation = eleData.rotation
	local rotationCenter = eleData.rotationCenter
	if shadow then
		local shadowoffx,shadowoffy,shadowc,shadowIsOutline = shadow[1],shadow[2],shadow[3],shadow[4]
		local textX,textY = x,y
		if shadowoffx and shadowoffy and shadowc then
			local shadowc = applyColorAlpha(shadowc,parentAlpha)
			local shadowText = colorcoded and text:gsub('#%x%x%x%x%x%x','') or text
			dxDrawText(shadowText,textX+shadowoffx,textY+shadowoffy,textX+w+shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,false,subPixelPos,rotation,rotationCenter[1],rotationCenter[2])
			if shadowIsOutline then
				dxDrawText(shadowText,textX-shadowoffx,textY+shadowoffy,textX+w-shadowoffx,textY+h+shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,false,subPixelPos,rotation,rotationCenter[1],rotationCenter[2])
				dxDrawText(shadowText,textX-shadowoffx,textY-shadowoffy,textX+w-shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,false,subPixelPos,rotation,rotationCenter[1],rotationCenter[2])
				dxDrawText(shadowText,textX+shadowoffx,textY-shadowoffy,textX+w+shadowoffx,textY+h-shadowoffy,shadowc,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,false,subPixelPos,rotation,rotationCenter[1],rotationCenter[2])
			end
		end
	end
	dxDrawText(text,x,y,x+w,y+h,colors,txtSizX,txtSizY,font,alignment[1],alignment[2],clip,wordbreak,isPostGUI,colorcoded,subPixelPos,rotation,rotationCenter[1],rotationCenter[2])
	return rndtgt
end