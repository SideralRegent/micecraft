if not table.unpack then
    table.unpack = function(t)
        return t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10]
   end
end

local emptyFunc = function(...) end

local idFunc
do
	local count = -1
	idFunc = function()
		count = count + 1
		return count
	end
end

tfm = {
    enum = {
        bonus = {
            point = 0,
            speed = 1,
            death = 2,
            spring = 3,
            booster = 5,
            electricArc = 6
        },
        emote = {
            dance = 0,
            laugh = 1,
            cry = 2,
            kiss = 3,
            angry = 4,
            clap = 5,
            sleep = 6,
            facepaw = 7,
            sit = 8,
            confetti = 9,
            flag = 10,
            marshmallow = 11,
            selfie = 12,
            highfive = 13,
            highfive_1 = 14,
            highfive_2 = 15,
            partyhorn = 16,
            hug = 17,
            hug_1 = 18,
            hug_2 = 19,
            jigglypuff = 20,
            kissing = 21,
            kissing_1 = 22,
            kissing_2 = 23,
            carnaval = 24,
            rockpaperscissors = 25,
            rockpaperscissors_1 = 26,
            rockpaperscissor_2 = 27
        },
        ground = {
            wood = 0,
            ice = 1,
            trampoline = 2,
            lava = 3,
            chocolate = 4,
            earth = 5,
            grass = 6,
            sand = 7,
            cloud = 8,
            water = 9,
            stone = 10,
            snow = 11,
            rectangle = 12,
            circle = 13,
            invisible = 14,
            web = 15,
            yellowGrass = 17,
            pinkGrass = 18,
            acid = 19
        },
        particle = {
            whiteGlitter = 0,
            blueGlitter = 1,
            orangeGlitter = 2,
            cloud = 3,
            dullWhiteGlitter = 4,
            heart = 5,
            bubble = 6,
            tealGlitter = 9,
            spirit = 10,
            yellowGlitter = 11,
            ghostSpirit = 12,
            redGlitter = 13,
            waterBubble = 14,
            plus1 = 15,
            plus10 = 16,
            plus12 = 17,
            plus14 = 18,
            plus16 = 19,
            meep = 20,
            redConfetti = 21,
            greenConfetti = 22,
            blueConfetti = 23,
            yellowConfetti = 24,
            diagonalRain = 25,
            curlyWind = 26,
            wind = 27,
            rain = 28,
            star = 29,
            littleRedHeart = 30,
            littlePinkHeart = 31,
            daisy = 32,
            bell = 33,
            egg = 34,
            projection = 35,
            mouseTeleportation = 36,
            shamanTeleportation = 37,
            lollipopConfetti = 38,
            yellowCandyConfetti = 39,
            pinkCandyConfetti = 40
        },
        shamanObject = {
            arrow = 0,
            littleBox = 1,
            box = 2,
            littleBoard = 3,
            board = 4,
            ball = 6,
            trampoline = 7,
            anvil = 10,
            cannon = 17,
            bomb = 23,
            orangePortal = 26,
            blueBalloon = 28,
            redBalloon = 29,
            greenBalloon = 30,
            yellowBalloon = 31,
            rune = 32,
            chicken = 33,
            snowBall = 34,
            cupidonArrow = 35,
            apple = 39,
            sheep = 40,
            littleBoardIce = 45,
            littleBoardChocolate = 46,
            iceCube = 54,
            cloud = 57,
            bubble = 59,
            tinyBoard = 60,
            companionCube = 61,
            stableRune = 62,
            balloonFish = 65,
            longBoard = 67,
            triangle = 68,
            sBoard = 69,
            paperPlane = 80,
            rock = 85,
            pumpkinBall = 89,
            tombstone = 90,
            paperBall = 95
        }
    },
    exec = {
		addNPC = emptyFunc,
        addBonus = emptyFunc,
        addConjuration = emptyFunc,
        addImage = idFunc,
        addJoint = idFunc,
        addPhysicObject = idFunc,
        addShamanObject = idFunc,
        attachBalloon = emptyFunc,
        bindKeyboard = emptyFunc,
        changePlayerSize = emptyFunc,
        chatMessage = emptyFunc,--function(a) print("\t\t" .. tostring(a))end,
        disableAfkDeath = emptyFunc,
        disableAllShamanSkills = emptyFunc,
        disableAutoNewGame = emptyFunc,
        disableAutoScore = emptyFunc,
        disableAutoShaman = emptyFunc,
        disableAutoTimeLeft = emptyFunc,
        disableDebugCommand = emptyFunc,
        disableMinimalistMode = emptyFunc,
        disableMortCommand = emptyFunc,
        disablePhysicalConsumables = emptyFunc,
        disablePrespawnPreview = emptyFunc,
        disableWatchCommand = emptyFunc,
        displayParticle = emptyFunc,
        explosion = emptyFunc,
        freezePlayer = emptyFunc,
        getPlayerSync = emptyFunc,
        giveCheese = emptyFunc,
        giveConsumables = emptyFunc,
        giveMeep = emptyFunc,
        giveTransformations = emptyFunc,
        killPlayer = emptyFunc,
        linkMice = emptyFunc,
        lowerSyncDelay = emptyFunc,
        moveObject = emptyFunc,
        movePlayer = emptyFunc,
        newGame = function()
            if eventNewGame then
                eventNewGame()
                if eventLoop then
                    for i=1, 20 do
                        eventLoop(math.random(499, 551), 120000 - (500 * i))
                    end
                end
            end
        end,
        playEmote = emptyFunc,
		playMusic = emptyFunc,
		stopMusic = emptyFunc,
		playSound = emptyFunc,
        playerVictory = emptyFunc,
        removeBonus = emptyFunc,
        removeCheese = emptyFunc,
        removeImage = emptyFunc,
        removeJoint = emptyFunc,
        removeObject = emptyFunc,
        removePhysicObject = emptyFunc,
        respawnPlayer = emptyFunc,
        setAieMode = emptyFunc,
        setAutoMapFlipMode = emptyFunc,
        setGameTime = emptyFunc,
        setNameColor = emptyFunc,
        setNightMode = emptyFunc,
        setPlayerGravityScale = emptyFunc,
        setPlayerSync = emptyFunc,
        setPlayerScore = emptyFunc,
        setRoomMaxPlayers = emptyFunc,
        setRoomPassword = emptyFunc,
        setShaman = emptyFunc,
        setShamanMode = emptyFunc,
        setUIMapName = emptyFunc,
        setUIShamanName = emptyFunc,
        setVampirePlayer = emptyFunc,
        setWorldGravity = emptyFunc,
        snow = emptyFunc
    },
    get = {
        misc = {
            apiVersion = "0.28",
            transformiceVersion = "6.09"
        },
        room = {
            community = "-",
            language = "int",
            isTribeHouse = false,
            currentMap = 0,
            maxPlayers = 50,
            mirroredMap = false,
            name = "en-#micecraft",
            objectList = {
                [1] = {
                    angle = 0,
                    baseType = 2,
                    colors = {
                        1,
                        2,
                        3
                    },
                    ghost = false,
                    id = 1,
                    type = 203,
                    vx = 0,
                    vy = 0,
                    x = 400,
                    y = 200
                }
            },
            passwordProtected = false,
            playerList = {
                ["Tigrounette#0001"] = {
                    cheeses = 0,
                    community = "en",
                    gender = 0,
                    hasCheese = false,
                    id = 0,
                    inHardMode = 0,
                    isDead = true,
                    isFacingRight = true,
                    isInvoking = false,
                    isJumping = false,
                    isShaman = false,
                    isVampire = false,
                    language = 'int',
                    look = "1;0,0,0,0,0,0,0,0,0",
                    movingLeft = false,
                    movingRight = false,
                    playerName = "Tigrounette#0001",
                    registrationDate = 0,
                    score = 0,
                    shamanMode = 0,
                    spouseId = 1,
                    spouseName = "Pikashu#0095",
                    title = 0,
                    tribeId = 1234,
                    tribeName = "Kikoo",
                    vx = 0,
                    vy = 0,
                    x = 0,
                    y = 0
                }
            },
            uniquePlayers = 1,
            xmlMapInfo = {
                author = "Tigrounette#0001",
                mapCode = 184924,
                permCode = 1,
                xml = '<C><P /><Z><S /><D /><O /></Z></C>'
            }
        }
    }
}

ui = {
    addPopup = emptyFunc,
    addTextArea = emptyFunc,
    removeTextArea = emptyFunc,
    setBackgroundColor = emptyFunc,
    setMapName = emptyFunc,
    setShamanName = emptyFunc,
    showColorPicker = emptyFunc,
    updateTextArea = emptyFunc
}

system = {
    bindKeyboard = emptyFunc,
    bindMouse = emptyFunc,
    disableChatCommandDisplay = emptyFunc,
    exit = function() os.exit(0) end,
    giveEventGift = emptyFunc,
    loadFile = emptyFunc,
    loadPlayerData = function(playerName) if eventPlayerDataLoaded then eventPlayerDataLoaded(playerName, "") end; end,
	luaEventLaunchInterval = emptyFunc,
    newTimer = function(c, t, l, ...) if c then c(...) end; end,
    removeTimer = emptyFunc,
    saveFile = emptyFunc,
    savePlayerData = emptyFunc
}