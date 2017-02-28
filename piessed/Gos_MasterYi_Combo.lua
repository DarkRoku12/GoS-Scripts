
-- Created By DarkRoku12 -- 2017.

require "orbwalker"

local chrono_mt =
{
   __index =
  {
    now = function( self )
        return self._imp() - self.prev ;
    end ,

    restart = function( self )
      local prev = self.prev ;
        self.prev = self._imp()
      return self.prev - prev ;
    end
  } ,

}

local function newChrono( imp )
   return setmetatable( { _imp = os.clock , prev = os.clock() } , chrono_mt )
end

local myHero = myHero ;

local function isThisChampion( name )
   return myHero.charName:lower() == name:lower() ;
end 

if not isThisChampion( "masteryi" ) then
   return 
end 

local mouse = 
{
   wheel = WM_MOUSEHWHEEL ,

   right = 
   {
    up   = WM_RBUTTONUP ,
    down = WM_RBUTTONDOWN ,
   } , 

   left = 
   {
    up   = WM_LBUTTONUP ,
    down = WM_LBUTTONDOWN ,
   } , 

   middle = 
   {
    up   = WM_MBUTTONUP ,
    down = WM_MBUTTONDOWN ,
   } ,

}

local key = 
{
   up    = KEY_UP ,
   down  = KEY_DOWN ,
   Q     = 81 , 
   W     = 87 , 
   E     = 69 , 
   R     = 82 ,
   H     = 72 , 
   L     = 76 , 
   O     = 79 , 
   P     = 80 , 
   Z     = 90 ,
   Space = 32 , 
   Num0  = 48 ,
   Num1  = 49 ,
   Num2  = 50 , 
   Num3  = 51 , 
   Num4  = 52 , 
   Num5  = 53 , 
   Num6  = 54 , 
   Num7  = 55 , 
   Num8  = 56 , 
   Num9  = 57 ,  
}

local ItemMap = 
{
  key = { HK_ITEM_1 , HK_ITEM_2 , HK_ITEM_3 , HK_ITEM_4 , HK_ITEM_5 , HK_ITEM_6 , HK_ITEM_7 } ,
  ITEM_1 ,
  ITEM_2 ,
  ITEM_3 ,
  ITEM_4 ,
  ITEM_5 ,
  ITEM_6 ,
  ITEM_7 ,
  -- blade_of_ruined_king = 5153 ,
  blade_of_ruined_king = 3153 ,  
}

setmetatable( ItemMap , { __index = function( self , idx ) error( "Invalid item ID #: " .. idx ) end } )


--[[
--> Index between 1 ~ 6 
    1 - 4 => Q W E R skills 
    5 - 6 => D F skills.
]]
local function getSpell( idx ) 
   return myHero:GetSpellData( idx - 1 ) ;
end 

local function getItem( idx ) --> Return the item by index [ 1 ~ 7 ]
  local index = ItemMap[ idx ] ;
   local item  = myHero:GetItemData( index ) ;
         item.index = idx ;
         item.key   = ItemMap.key[ idx ] ;
   return item ;
end 

local function findItem( itemID ) --> ID of the item to be found.
   for i = 1 , 7 do --> Loop for every item.
      local item = getItem( i ) 
      if item.itemID == itemID then --> Item found.
         return item ;
      end 
   end 
   return false ;  
end   

local drawParams = 
{
   bladeNotFound = false ,  
   bladeTimer = newChrono() ,
   debug = false ,
}

-- Executed every frame:
Callback.Add( "Draw" ,

function()
   
   -- Activated if the user press 'SpaceBar' and the Item (Blade of Ruined King if not found)
   
   if drawParams.debug then 
      Draw.Text( drawParams.debug , 10 , 60 , 15 , Draw.Color( 255 , 255 , 255 , 0 ) )
   end 

   Draw.Circle( myHero.pos , getSpell( 1 ).range , Draw.Color( 255 , 255 , 255 , 0 ) )

  if drawParams.bladeNotFound then  
    
    local bladeTimer = drawParams.bladeTimer ;

    if bladeTimer:now() >= 3 then --> 3 seconds have passed?
         drawParams.bladeNotFound = false ; 
    end 

     local red = Draw.Color( 255 , 255 , 0 , 0 )
      
      Draw.Text( "Blade of Ruined King not found!!!" , 30 , 60 , 60 , red )

   end

end 

)


local function CastAttack()
  Control.SetCursorPos( myHero.pos )
  Control.mouse_event(MOUSEEVENTF_RIGHTDOWN)
  Control.mouse_event(MOUSEEVENTF_RIGHTUP)
end

local function canCast( idx )
  local spell = getSpell( idx )
   return spell.currentCd == 0 and spell.level > 0 ;
end 

local function attackNearest()
   local target = EOW:GetTarget() ;
   if target then 
      Order:Attack( target )
   end
end 

local Combo ;

local blade_key = false ;

Combo = 
{
   function() -- 1

    local ultimate = getSpell( 4 ) --> Get spell 'R'.
      
      --> Is the ultimate available? If yes, cast it.
    if ultimate.level > 0 then 
         Control.CastSpell( "R" ) ; --> Cast
    end

    DelayAction( Combo[2] , 0.1 ) 

   end ,

   function() -- 2
    -- Step #2 
    local blade = findItem( ItemMap.blade_of_ruined_king ) ;

    if not findItem( ItemMap.blade_of_ruined_king ) then 
      --> Not found? So emit (draw) a visible warning.
       drawParams.bladeTimer:restart()
         drawParams.bladeNotFound = true ;
      else --> Found? Use it!
        blade_key = blade.key ;
         Control.KeyDown( blade.key ) ; 
    end 

    DelayAction( Combo[3] , 0.1 )

   end , 

   function() -- 3

    if blade_key then 
         Control.KeyUp( blade_key ) ;
      end 
    -- Step #3 -- Enemy is far? So use Q to be near.
    if not EOW:GetTarget() then 
         Control.CastSpell( "Q" ) ;
    end 

    DelayAction( Combo[4] , 0.1 )

   end ,
   
   function() -- 4
    Control.CastSpell( "E" ) ; --> Cast E. 
    DelayAction( Combo[5] , 0.1 )
    DelayAction( CastAttack , 0.05 )
   end , 

   function() -- 5
    
    Control.CastSpell( "W" ) ; --> To reset Auto Attack.
    
    if canCast( 3 ) then 
         DelayAction( Combo[4] , 0.1 )
    end 

    attackNearest()

    -- DelayAction( attackNearest , 0.2 )      

   end 

}

Callback.Add( "WndMsg" , 

function( msg , value ) 

  if msg == key.up then

     if value == key.Z then 

         DelayAction( Combo[1] , 0.1 )

      end
  
  end 

end
)

