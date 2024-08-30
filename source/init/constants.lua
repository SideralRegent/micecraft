local BOX2D_MAX_SIZE = 32767 -- Constant according to game limitations. Do not modify!
local TEXTURE_SIZE = 32 -- Constant according to assets uploaded. Do not modify !
local REFERENCE_SCALE = 1.0
local REFERENCE_SCALE_X = 1.0
local REFERENCE_SCALE_Y = 1.0

-- Shape constants for fetching stuff
local SH_SQR = 1 -- Square
local SH_CRS = 2 -- Cross
local SH_CRN = 3 -- Corner
local SH_UND = 4 -- Underscore
local SH_LNR = 5 -- Left and right

-- Coordinate constants for translation among systems
local CD_MTX = 1 -- Matrix
local CD_MAP = 2 -- Map
local CD_UID = 3 -- Unique ID
local CD_BLK = 4 -- Block

local FL_FILL = 4
local FL_EMPTY = 0

local T_NULL = 0
local T_INF = -1