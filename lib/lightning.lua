local imgui = require('mimgui')

local Lightning = {}

-- Configuración mejorada para rayos más realistas
local lightningConfig = {
    maxBranches = 12,
    maxSegments = 25,
    branchProbability = 0.4,
    zigzagIntensity = 60,
    thickness = 8.0,
    fadeSpeed = 0.03,
    spawnRate = 0.08, -- Menos frecuente pero más impactante
    duration = 1.5,
    glowLayers = 6,
    -- Color más eléctrico y realista
    colorR = 0.9,
    colorG = 0.7,
    colorB = 1.0,
    -- Nuevos parámetros para realismo
    mainBoltThickness = 12.0,
    branchThickness = 6.0,
    flickerIntensity = 0.8,
    glowRadius = 25.0
}

local activeLightning = {}
local lastSpawnTime = 0
local screenWidth = 1920
local screenHeight = 1080

-- Función mejorada para generar puntos aleatorios más naturales
local function randomOffset(intensity, progress)
    -- Más variación al inicio y menos al final para mayor realismo
    local variationMultiplier = 1.0 - (progress * 0.3)
    return (math.random() - 0.5) * intensity * 2 * variationMultiplier
end

-- Función para crear puntas realistas de rayos
local function createLightningTip(x, y, direction, length)
    local tips = {}
    local baseAngle = math.atan2(direction.y, direction.x)
    
    -- Crear múltiples puntas pequeñas
    for i = 1, 3 do
        local tipAngle = baseAngle + (math.random() - 0.5) * 0.8
        local tipLength = length * (0.3 + math.random() * 0.4)
        
        table.insert(tips, {
            x = x + math.cos(tipAngle) * tipLength,
            y = y + math.sin(tipAngle) * tipLength
        })
    end
    
    return tips
end

-- Función mejorada para generar rayos grandes y realistas
local function generateLightningBolt(startX, startY, endX, endY, generation, isMainBolt)
    local bolt = {
        segments = {},
        branches = {},
        tips = {},
        alpha = 1.0,
        startTime = os.clock(),
        generation = generation or 0,
        isMainBolt = isMainBolt or false,
        thickness = isMainBolt and lightningConfig.mainBoltThickness or 
                   (lightningConfig.branchThickness * (1.0 - generation * 0.4))
    }
    
    -- Calcular la distancia y dirección
    local deltaX = endX - startX
    local deltaY = endY - startY
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    local segments = math.min(lightningConfig.maxSegments, math.max(5, distance / 40))
    
    -- Generar segmentos del rayo principal con más naturalidad
    local currentX, currentY = startX, startY
    bolt.segments[1] = {x = currentX, y = currentY}
    
    for i = 2, segments do
        local progress = (i - 1) / (segments - 1)
        local targetX = startX + deltaX * progress
        local targetY = startY + deltaY * progress
        
        -- Zigzag más natural y realista
        local zigzagX = randomOffset(lightningConfig.zigzagIntensity, progress)
        local zigzagY = randomOffset(lightningConfig.zigzagIntensity, progress)
        
        -- Añadir curvatura natural
        local curvature = math.sin(progress * math.pi) * 30
        zigzagX = zigzagX + curvature * (math.random() - 0.5)
        
        currentX = targetX + zigzagX
        currentY = targetY + zigzagY
        
        bolt.segments[i] = {x = currentX, y = currentY}
        
        -- Generar ramas más realistas
        if generation < 3 and math.random() < lightningConfig.branchProbability then
            local branchLength = distance * (0.2 + math.random() * 0.6)
            local branchAngle = math.random() * math.pi * 2
            
            -- Hacer que las ramas sigan direcciones más naturales
            if generation == 0 then
                branchAngle = math.atan2(deltaY, deltaX) + (math.random() - 0.5) * 1.5
            end
            
            local branchEndX = currentX + math.cos(branchAngle) * branchLength
            local branchEndY = currentY + math.sin(branchAngle) * branchLength
            
            table.insert(bolt.branches, generateLightningBolt(currentX, currentY, branchEndX, branchEndY, generation + 1, false))
        end
    end
    
    -- Crear puntas realistas al final del rayo
    if #bolt.segments >= 2 then
        local lastSeg = bolt.segments[#bolt.segments]
        local prevSeg = bolt.segments[#bolt.segments - 1]
        local direction = {
            x = lastSeg.x - prevSeg.x,
            y = lastSeg.y - prevSeg.y
        }
        bolt.tips = createLightningTip(lastSeg.x, lastSeg.y, direction, bolt.thickness * 2)
    end
    
    return bolt
end

-- Función mejorada para dibujar líneas con efecto de brillo realista
local function drawThickLine(x1, y1, x2, y2, color, thickness, alpha, isMainBolt)
    local drawList = imgui.GetWindowDrawList()
    
    -- Más capas de brillo para rayos principales
    local glowLayers = isMainBolt and lightningConfig.glowLayers + 2 or lightningConfig.glowLayers
    
    -- Dibujar brillo exterior
    for layer = glowLayers, 1, -1 do
        local layerThickness = thickness * (1 + layer * 0.8)
        local layerAlpha = alpha * (0.15 / layer)
        
        local layerColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(
            color.x * 1.2,
            color.y * 1.2,
            color.z,
            layerAlpha
        ))
        
        drawList:AddLine(
            imgui.ImVec2(x1, y1),
            imgui.ImVec2(x2, y2),
            layerColor,
            layerThickness
        )
    end
    
    -- Núcleo brillante del rayo
    local coreColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(
        math.min(1.0, color.x * 1.5),
        math.min(1.0, color.y * 1.5),
        1.0,
        alpha
    ))
    
    drawList:AddLine(
        imgui.ImVec2(x1, y1),
        imgui.ImVec2(x2, y2),
        coreColor,
        thickness * 0.3
    )
end

-- Función para dibujar las puntas del rayo
local function drawLightningTips(tips, color, thickness, alpha)
    local drawList = imgui.GetWindowDrawList()
    
    for _, tip in ipairs(tips) do
        -- Dibujar pequeños destellos en las puntas
        for i = 1, 3 do
            local tipColor = imgui.ColorConvertFloat4ToU32(imgui.ImVec4(
                color.x,
                color.y,
                color.z,
                alpha * (0.8 / i)
            ))
            
            drawList:AddCircleFilled(
                imgui.ImVec2(tip.x, tip.y),
                thickness * 0.5 * i,
                tipColor
            )
        end
    end
end

-- Función mejorada para dibujar un rayo completo
local function drawLightningBolt(bolt, baseAlpha)
    local currentTime = os.clock()
    local elapsed = currentTime - bolt.startTime
    local fadeAlpha = math.max(0, 1.0 - (elapsed / lightningConfig.duration))
    
    -- Efecto de parpadeo más realista
    local flickerAlpha = 1.0
    if math.random() < lightningConfig.flickerIntensity then
        flickerAlpha = 0.3 + math.random() * 0.7
    end
    
    local finalAlpha = baseAlpha * fadeAlpha * bolt.alpha * flickerAlpha
    
    if finalAlpha <= 0 then
        return false
    end
    
    -- Color más eléctrico y variable
    local lightningColor = {
        x = lightningConfig.colorR + (math.random() - 0.5) * 0.2,
        y = lightningConfig.colorG + (math.random() - 0.5) * 0.2,
        z = lightningConfig.colorB,
    }
    
    -- Dibujar segmentos principales
    for i = 1, #bolt.segments - 1 do
        local seg1 = bolt.segments[i]
        local seg2 = bolt.segments[i + 1]
        
        drawThickLine(
            seg1.x, seg1.y,
            seg2.x, seg2.y,
            lightningColor,
            bolt.thickness,
            finalAlpha,
            bolt.isMainBolt
        )
    end
    
    -- Dibujar puntas
    if #bolt.tips > 0 then
        drawLightningTips(bolt.tips, lightningColor, bolt.thickness, finalAlpha)
    end
    
    -- Dibujar ramas recursivamente
    for _, branch in ipairs(bolt.branches) do
        drawLightningBolt(branch, finalAlpha * 0.8)
    end
    
    return true
end

-- Función para crear rayos que cruzan toda la pantalla
function Lightning.createFullScreen(alpha)
    local currentTime = os.clock()
    
    -- Actualizar resolución de pantalla
    screenWidth, screenHeight = getScreenResolution()
    
    -- Crear nuevos rayos ocasionalmente (2 rayos máximo como pediste)
    if currentTime - lastSpawnTime > (1.0 / lightningConfig.spawnRate) and math.random() < 0.3 then
        lastSpawnTime = currentTime
        
        -- Limpiar rayos antiguos si hay más de 2
        if #activeLightning >= 2 then
            table.remove(activeLightning, 1)
        end
        
        -- Patrones de rayos que cruzan la pantalla
        local lightningPatterns = {
            -- Diagonal completa de esquina a esquina
            {
                startX = -100,
                startY = -100,
                endX = screenWidth + 100,
                endY = screenHeight + 100,
                isMain = true
            },
            -- Diagonal inversa
            {
                startX = screenWidth + 100,
                startY = -100,
                endX = -100,
                endY = screenHeight + 100,
                isMain = true
            },
            -- Vertical desde arriba
            {
                startX = screenWidth * (0.2 + math.random() * 0.6),
                startY = -200,
                endX = screenWidth * (0.2 + math.random() * 0.6),
                endY = screenHeight + 200,
                isMain = true
            },
            -- Horizontal
            {
                startX = -200,
                startY = screenHeight * (0.3 + math.random() * 0.4),
                endX = screenWidth + 200,
                endY = screenHeight * (0.3 + math.random() * 0.4),
                isMain = true
            },
            -- Zigzag dramático
            {
                startX = screenWidth * 0.1,
                startY = -100,
                endX = screenWidth * 0.9,
                endY = screenHeight + 100,
                isMain = true
            }
        }
        
        local selectedPattern = lightningPatterns[math.random(#lightningPatterns)]
        local newBolt = generateLightningBolt(
            selectedPattern.startX, selectedPattern.startY,
            selectedPattern.endX, selectedPattern.endY,
            0,
            selectedPattern.isMain
        )
        
        table.insert(activeLightning, newBolt)
    end
    
    -- Dibujar y actualizar rayos activos
    for i = #activeLightning, 1, -1 do
        local bolt = activeLightning[i]
        local stillActive = drawLightningBolt(bolt, alpha)
        
        if not stillActive then
            table.remove(activeLightning, i)
        end
    end
end

-- Función para limpiar todos los rayos
function Lightning.clear()
    activeLightning = {}
end

-- Función para configurar parámetros
function Lightning.setConfig(config)
    for key, value in pairs(config) do
        if lightningConfig[key] then
            lightningConfig[key] = value
        end
    end
end

return Lightning