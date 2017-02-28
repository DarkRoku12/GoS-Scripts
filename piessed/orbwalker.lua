
-- External OrbWalker.
-- Must be under 'Common' folder.

if EOWLoaded then
   return
end
EOWLoaded = true

class "Order"

function Order:__init()

   self.CastingSpell = false
   self.Attacking = false
   self.Moving = false
   self.BlockAttack = false
   self.BlockMovement = false
   self.BlockSpell = false
   SpellToKey = {
   [_Q] = HK_Q, 
   [_W] = HK_W, 
   [_E] = HK_E, 
   [_R] = HK_R, 
   [SUMMONER_1] = HK_SUMMONER_1, 
   [SUMMONER_2] = HK_SUMMONER_2,
   [ITEM_1] = HK_ITEM_1,
   [ITEM_2] = HK_ITEM_2,
   [ITEM_3] = HK_ITEM_3,
   [ITEM_4] = HK_ITEM_4,
   [ITEM_5] = HK_ITEM_5,
   [ITEM_6] = HK_ITEM_6,
   [ITEM_7] = HK_ITEM_7
   }

end

function Order:CastSpell(spell, pos)
   if self.BlockSpell or self.CastingSpell or self.Attacking or self.Moving or not SpellToKey[spell] or Game.CanUseSpell(spell) ~= 0 then
      return
   end
   self.CastingSpell = true
   local spell = SpellToKey[spell]
   if pos then
      local LastMousePos = mousePos
      Control.SetCursorPos(pos)
      DelayAction(function()
         Control.KeyDown(spell)
         Control.KeyUp(spell)
         DelayAction(function()
            Control.SetCursorPos(LastMousePos)
            DelayAction(function()
               self.CastingSpell = false
            end, 0.001)
         end, 0.001)
      end, 0.001)
   else
      Control.KeyDown(spell)
      Control.KeyUp(spell)
      self.CastingSpell = false
   end
end

function Order:RightClick()
   Control.mouse_event(0x0008)
   Control.mouse_event(0x0010)
end

function Order:Attack(unit)
   if self.BlockAttack or self.CastingSpell or self.Attacking or self.Moving then
      return
   end
   self.Attacking = true
   local LastMousePos = mousePos
   local TCO = HK_TCO
   if unit.type == Obj_AI_Hero then
      Control.KeyDown(TCO)
   else
      Control.KeyUp(TCO)
   end
   Control.SetCursorPos(unit.pos)
   DelayAction(function()
      self:RightClick()
      DelayAction(function()
         Control.SetCursorPos(LastMousePos)
         Control.KeyUp(TCO)
         DelayAction(function()
            self.Attacking = false
         end, 0.001)
      end, 0.001)
   end, 0.001)
end

function Order:Move(pos)
   if self.BlockMovement or self.CastingSpell or self.Attacking or self.Moving then
      return
   end
   self.Moving = true
   local TCO = HK_TCO
   Control.KeyDown(TCO)
   if pos then
      local LastMousePos = mousePos
      Control.SetCursorPos(pos)
      DelayAction(function()
         self:RightClick()
         DelayAction(function()
            Control.SetCursorPos(LastMousePos)
            Control.KeyUp(TCO)
            DelayAction(function()
               self.Moving = false
            end, 0.001)
         end, 0.001)
      end, 0.001)
   else
      self:RightClick()
      DelayAction(function()
         Control.KeyUp(TCO)
         self.Moving = false
      end, 0.001)
   end
end

function Order:BlockAttacks(bool)
   self.BlockAttack = bool 
end

function Order:BlockMovements(bool)
   self.BlockMovement = bool
end

function Order:BlockSpells(bool)
   self.BlockSpell = bool
end

class "EOW"

function EOW:__init()

   self.bonusDamageTable = {
      ["Aatrox"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg+ (self:GotBuff(source, "aatroxwonhpowerbuff") > 0 and ({60,95,130,165,200})[source:GetSpellData(_W).level] + source.baseDamage or 0), APDmg, TRUEDmg
      end,
      ["Ashe"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         local BonusCritDamage = self:GetItemSlot(source, 3031) > 0 and 0.5 or 0
         return ADDmg + (self:GotBuff(source, "asheqattack") > 0 and ({0.05,0.1,0.15,0.2,0.25})[source:GetSpellData(_Q).level] * ADDmg or self:GotBuff(target, "ashepassiveslow") > 0 and ADDmg*(0.1 + (source.critChance * (1 + BonusCritDamage))) or 1), APDmg, TRUEDmg
      end,
      --[[["Akali"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (ADDmg * (0.06 + ((source.ap / 6) * 0.01))), TRUEDmg
      end,]]
      ["Bard"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "bardpspiritammocount") > 0 and 30 + source.levelData.lvl * 15 + 0.3 * source.ap or 0), TRUEDmg
      end,
      ["Blitzcrank"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg * (self:GotBuff(source, "powerfist") + 1), APDmg, TRUEDmg
      end,
      --[[["Braum"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (GetBuffData(target, "").Count == 3 and 16 + (10 * source.levelData.lvl) or 0), TRUEDmg
      end,]]
      ["Caitlyn"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "caitlynheadshot") > 0 and 1.5*(ADDmg) or 0), APDmg, TRUEDmg
      end,
      ["Chogath"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "vorpalspikes") > 0 and 15 * source:GetSpellData(_E).level + 5 + .3 * source.ap or 0), APDmg, TRUEDmg
      end,
      ["Corki"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg * 0.5, APDmg + (ADDmg * 0.5), TRUEDmg
      end,
      ["Darius"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "dariusnoxiantacticsonh") > 0 and .4*(ADDmg) or 0), APDmg, TRUEDmg
      end,
      ["Diana"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "dianaarcready") > 0 and math.max(5*source.levelData.lvl+15,10*source.levelData.lvl-10,15*source.levelData.lvl-60,20*source.levelData.lvl-125,25*source.levelData.lvl-200)+.8*source.ap or 0), TRUEDmg
      end,
      ["Draven"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "DravenSpinning") > 0 and (({0.45,0.55,0.65,0.75,0.85})[source:GetSpellData(_Q).level] * ADDmg) or 0), APDmg, TRUEDmg
      end,
      --[[["DrMundo"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "") > 0 and ({0.03, 0.035, 0.04, 0.045, 0.05})[source:GetSpellData(_E).level] * source.maxHealth)
      end,]]
      ["Ekko"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "ekkoeattackbuff") > 0 and 30*source:GetSpellData(_E).level+20+.2*source.ap or 0) + (self:GotBuff(target, "") == 2 and (10 + (10 * source.levelData.lvl)) + source.ap or 0), TRUEDmg
      end,  
      ["Fizz"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "fizzseastonepassive") > 0 and 5*source:GetSpellData(_W).level+5+.3*source.ap or 0), TRUEDmg
      end,
      --[[["Fiora"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "") > 0 and source.totalDamage + ({1.4, 1.55, 1.7, 1.85, 2})[source:GetSpellData(_E).level] or 0), APDmg, TRUEDmg
      end,]]
      ["Garen"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "garenq") > 0 and 25*source:GetSpellData(_Q).level+5+.4*(ADDmg) or 0), APDmg, TRUEDmg
      end,
      --[[["Gnar"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(target, "") == 2 and ((10 * source:GetSpellData(_W).level) + ([0.06, 0.08, 0.1, 0.12, 0.14])[source:GetSpellData(_W).level] * source.maxHealth) + source.ap or 0), TRUEDmg
      end,]]
      ["Graves"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         local BonusCritDamage = self:GetItemSlot(source, 3031) > 0 and 0.5 or 0
         local BaseDamage = ({70,71,72,74,75,76,78,80,81,83,85,87,89,91,95,96,97,100})[myHero.levelData.lvl]
         return source.critChance == 1 and BaseDamage + (ADDmg * (0.4 * (1 + BonusCritDamage))) or BaseDamage, APDmg, TRUEDmg
      end,
      ["Gragas"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "gragaswattackbuff") > 0 and 30*source:GetSpellData(_W).level-10+.3*source.ap+(.01*source:GetSpellData(_W).level+.07) * target.maxHealth or 0), TRUEDmg
      end,
      ["Irelia"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, 0, TRUEDmg + (self:GotBuff(source, "ireliahitenstylecharged") > 0 and 25*source:GetSpellData(_W).level+5+.4*(ADDmg) or 0)
      end,
      ["Ivern"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "ivernwpassive") > 0 and (10+10*source:GetSpellData(_W).level) + (source.ap*0.3) or 0), TRUEDmg
      end,     
      ["Illaoi"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "IllaoiW") > 0 and math.min(300, ({0.03, 0.035, 0.04, 0.045, 0.05})[source:GetSpellData(_W).level] + (0.02 * (ADDmg / 100)) * source.maxHealth) or 0), APDmg, TRUEDmg
      end,
      ["Jax"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "jaxempowertwo") > 0 and 35*source:GetSpellData(_W).level+5+.6*source.ap or 0), TRUEDmg
      end,
      ["Jayce"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg * (self:GotBuff(source, "JayceHyperCharge") and (0.68 + 0.08 * source:GetSpellData(_W).level) or 1), APDmg + (self:GotBuff(source, "jaycepassivemeleeatack") > 0 and 40*source:GetSpellData(_R).level-20+.4*source.ap or 0), TRUEDmg
      end,
      ["Jhin"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "jhinpassiveattackbuff") > 0 and (((target.maxHealth - target.health) * ({0.15,0.15,0.15,0.15,0.15,0.2,0.2,0.2,0.2,0.2,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25})[myHero.levelData.lvl])) or 0), APDmg, TRUEDmg
      end,
      ["Jinx"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "JinxQ") > 0 and .1*(ADDmg) or 0), APDmg, TRUEDmg
      end,
      ["Kalista"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg * 0.9, APDmg, TRUEDmg
      end,
      ["Kindred"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (target.health * (self:GotBuff(source, "kindredmarkofthekindredstackcounter")) * 0.0125), APDmg, TRUEDmg
      end,
      ["Kassadin"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "netherbladebuff") > 0 and 20+.1*source.ap or (self:GotBuff(source, "netherblade") > 0 and 25*source:GetSpellData(_W).level+15+.6*source.ap or 0)), TRUEDmg
      end,
      --[[["KogMaw"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + ( self:GotBuff(source, "") > 0 and (({0.02,0.03,0.04,0.05,0.06})[source:GetSpellData(_W).level] + math.floor(source.ap/100)/100) * source.maxHealth or 0) , TRUEDmg
      end,]]
      ["Katarina"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(target, "katarinaqmark") > 0 and ((15 * source:GetSpellData(_Q).level) + (source.ap * 0.2)) or 0), TRUEDmg 
      end,
      ["Kayle"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "kaylerighteousfurybuff") > 0 and 5*source:GetSpellData(_E).level+5+.15*source.ap or 0) + (self:GotBuff(source, "judicatorrighteousfury") > 0 and 5*source:GetSpellData(_E).level+5+.15*source.ap or 0), TRUEDmg
      end,
      --[[["Kled"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Leona"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "leonashieldofdaybreak") > 0 and 30*source:GetSpellData(_Q).level+10+.3*source.ap or 0), TRUEDmg
      end,
      ["Lux"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "luxilluminatingfraulein") > 0 and 10+(source.levelData.lvl*8)+(source.ap*0.2) or 0), TRUEDmg
      end,
      --[[["Lulu"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Lucian"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "lucianpassivebuff") > 0 and (({0.3,0.3,0.3,0.3,0.3,0.4,0.4,0.4,0.4,0.4,0.5,0.5,0.5,0.5,0.5,0.6,0.6,0.6})[myHero.levelData.lvl] * ADDmg) or 0), APDmg, TRUEDmg
      end,
      ["MasterYi"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "doublestrike") > 0 and .5*(ADDmg) or 0), APDmg, TRUEDmg --[[+ (self:GotBuff(source, "") and ({14,23,32,41,50})[source:GetSpellData(_E).level] + (GetBonusDmg(source)*0.25) or 0)]]
      end,
      --[[["Malphite"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Nocturne"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "nocturneumrablades") > 0 and .2*(ADDmg) or 0), APDmg, TRUEDmg
      end,
      --[[["Nasus"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "NasusQ") > 0 and ({30,50,70,90,110})[source:GetSpellData(_Q).level] + GotBuff(source, "NasusQStacks").Stacks or 0) , APDmg, TRUEDmg
      end,]]
      ["Nidalee"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, ADDmg + (self:GotBuff(source, "Takedown") > 0 and math.max(({5,30,55,80})[source:GetSpellData(_R).level] + (ADDmg * 0.75) + (source.ap*0.4), ({1,1.25,1.5,1.75})[source:GetSpellData(_R).level] * math.min((((source.maxHealth - target.health) / source.maxHealth) * 100), ({1,1.25,1.5,1.75})[source:GetSpellData(_R).level])) or 0), TRUEDmg
      end,
      ["Orianna"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + 10 + 8 * math.ceil(source.levelData.lvl/3) + 0.15*source.ap, TRUEDmg
      end,
      ["Poppy"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "poppypassivebuff") and 10*source.levelData.lvl or 0), TRUEDmg
      end,  
      ["Quinn"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(target, "QuinnW") > 0 and ({15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100})[source.levelData.lvl] + (({0.16,0.18,0.20,0.22,0.24,0.26,0.28,0.30,0.32,0.34,0.36,0.38,0.40,0.42,0.44,0.46,0.48,0.50})[source.levelData.lvl] * ADDmg) or 0), APDmg, TRUEDmg
      end,  
      ["RekSai"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "reksaiq") > 0 and 10*source:GetSpellData(_Q).level+5+.2*(ADDmg) or 0), APDmg, TRUEDmg
      end,
      ["Rengar"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "rengarqbase") > 0 and ({30,60,90,120,150})[source:GetSpellData(_Q).level] + ADDmg * ({0,0.05,0.1,0.15,0.2})[source:GetSpellData(_Q).level] or 0) + (self:GotBuff(source, "rengarqemp") > 0 and ({30,45,60,75,90,105,120,135,150,160,170,180,190,200,210,220,230,240})[source.levelData.lvl] + (0.3*ADDmg) or 0), APDmg, TRUEDmg
      end,
      ["Shyvana"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "shyvanadoubleattack") > 0 and (.05*source:GetSpellData(_Q).level+.75)*(ADDmg) or 0), APDmg, TRUEDmg
      end,
      --[[["Sona"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Talon"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "talonnoxiandiplomacybuff") > 0 and 30*source:GetSpellData(_Q).level+.3*(source.bonusDamage) or 0), APDmg, TRUEDmg
      end,
      ["Teemo"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + 10*source:GetSpellData(_E).level+0.3*source.ap, TRUEDmg
      end,
      ["Trundle"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "trundletrollsmash") > 0 and 20*source:GetSpellData(_Q).level+((0.05*source:GetSpellData(_Q).level+0.095)*(ADDmg)) or 0), APDmg, TRUEDmg
      end,
      ["TwistedFate"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + ( self:GotBuff(source, "cardmasterstackparticle") > 0 and ({55,80,105,130,155})[source:GetSpellData(_E).level] + source.ap*0.5 or 0) + (self:GotBuff(source, "BlueCardPreAttack") > 0 and ({40,60,80,100,120})[source:GetSpellData(_W).level] + source.ap*0.5 or 0) + (self:GotBuff(source, "RedCardPreAttack") > 0 and ({30,45,60,75,90})[source:GetSpellData(_W).level] + source.ap*0.05 or 0) + (self:GotBuff(source, "GoldCardPreAttack") > 0 and ({15,22.5,30,37.5,45})[source:GetSpellData(_W).level] + source.ap*0.5 or 0), TRUEDmg
      end,  
      --[[["Udyr"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Varus"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(source, "varusw") > 0 and (4*source:GetSpellData(_W).level+6+.25*source.ap) or 0) , TRUEDmg
      end,
      ["Vayne"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (SourceBuffs["vaynetumblebonus"] and (0.2 + 0.1 * (source:GetSpellData(_Q).level)) * (ADDmg) or 0), APDmg, TRUEDmg + (TargetBuffs["VayneSilveredDebuff"] == 2 and math.max(20 + 20 * source:GetSpellData(_W).level, (target.maxHealth * (0.045 + 0.015 * source:GetSpellData(_W).level))) or 0)
      end,
      ["Vi"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "vie") > 0 and 15*source:GetSpellData(_E).level-10+.15*(ADDmg)+.7 * source.ap or 0) , APDmg, TRUEDmg
      end,
      --[[["Viktor"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Volibear"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "volibearq") > 0 and 30*source:GetSpellData(_Q).level or 0), APDmg, TRUEDmg
      end,
      --[[["MonkeyKing"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Rumble"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (source.mana == 100 and 20+(5*source.levelData.lvl) + source.ap*0.3 or 0), TRUEDmg
      end,  
      ["Riven"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg + (self:GotBuff(source, "rivenpassiveaaboost") > 0 and (({0.25,0.25,0.25,0.25,0.25,0.3,0.3,0.3,0.35,0.35,0.35,0.4,0.45,0.45,0.45,0.45,0.45,0.5})[source.levelData.lvl] * ADDmg) or 0), APDmg, TRUEDmg
      end,
      --[[["Yorick"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      --[[["Ziggs"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg, TRUEDmg
      end,]]
      ["Zed"] = function(source, target, ADDmg, APDmg, TRUEDmg, SourceBuffs, TargetBuffs)
         return ADDmg, APDmg + (self:GotBuff(target, "zedpassivecd") == 0 and target.health < (target.maxHealth*0.5) and target.maxHealth * ({0.06,0.06,0.06,0.06,0.06,0.06,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.08,0.1,0.1})[source.levelData.lvl] or 0), TRUEDmg
      end   
   }
   
   self.SpecialProjectiles = {
   ["Jhin"] = {name = "jhinpassiveattackbuff", speed = 3000},
   ["Jinx"] = {name = "JinxQ", speed = 2000},
   ["Gnar"] = {name = "gnartransform", speed = math.huge},
   ["Poppy"] = {name = "poppypassivebuff", speed = 1800},
   ["Ivern"] = {name = "ivernwpassive", speed = 1600},
   ["Viktor"] = {name = "ViktorPowerTransferReturn", speed = 3000}
   }  

   self.SpecialProjectiles2 = {
   ["Nidalee"] = {name = "Takedown", speed = math.huge},
   ["Jayce"] = {name = "JayceToTheSkies", speed = math.huge},
   ["Elise"] = {name = "EliseSpiderQCast", speed = math.huge}     
   }
   
   self.MinionDamage = {
   ["SRU_ChaosMinionMelee"] = 0.45,
   ["SRU_ChaosMinionRanged"] = 0.7,
   ["SRU_ChaosMinionSiege"] = 0.14,
   ["SRU_ChaosMinionSuper"] = 0.05,
   ["SRU_OrderMinionMelee"] = 0.45,
   ["SRU_OrderMinionRanged"] = 0.7,
   ["SRU_OrderMinionSiege"] = 0.14,
   ["SRU_OrderMinionSuper"] = 0.05
   }
   
   self.P = {
   [1] = {"Alistar", "Amumu", "Blitzcrank", "Braum", "ChoGath", "DrMundo", "Garen", "Gnar", "Hecarim", "JarvanIV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac", "Kled", "Illaoi", "TahmKench", "Bard"},
   [2] = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax","LeeSin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain","Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai"},
   [3] = {"Akali", "Diana", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Janna", "Jayce", "Kassadin","Kayle", "KhaZix", "Lissandra", "Mordekaiser", "Nami", "Nidalee", "Riven", "Shaco", "Sona", "Soraka", "TahmKench", "Vladimir", "Yasuo", "Zilean", "Zyra", "Kindred", "Ivern"},
   [4] = {"Ahri", "Anivia", "Annie", "Brand",  "Cassiopeia", "Ekko", "Karma", "Karthus", "Katarina", "Kennen", "LeBlanc",  "Lux", "Malzahar", "MasterYi", "Orianna", "Syndra", "Talon",  "TwistedFate", "Veigar", "VelKoz", "Viktor", "Xerath", "Zed", "Ziggs", "Taliyah", "AurelionSol"},
   [5] = {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne", "Jhin", "Camille"}
   }
   
   self.TargetSelector = {
   [1] = function() return self:EasyKill() end,
   [2] = function() return self:Closest() end,
   [3] = function() return self:ClosestM() end,
   [4] = function() return self:HighestAD() end,
   [5] = function() return self:HighestAP() end,
   [6] = function() return self:HighestHP() end,
   [7] = function() return self:LowestHP() end,
   [8] = function() return self:Priority() end
   }
   
   self.Channeling = {
   ["Caitlyn"] = function() return self:GotBuff(myHero, "CaitlynAceintheHole") == 0 end,
   ["Fiddlesticks"] = function() return self:GotBuff(myHero, "") == 0 and self:GotBuff(myHero, "") == 0 end,
   ["Galio"] = function() return self:GotBuff(myHero, "GalioIdolOfDurand") == 0 end,
   ["Janna"] = function() return self:GotBuff(myHero, "ReapTheWhirlwind") == 0 end,
   ["Karthus"] = function() return self:GotBuff(myHero, "karthusfallenonecastsound") == 0 end,
   ["Katarina"] = function() return self:GotBuff(myHero, "katarinarsound") == 0 end,
   ["Malzahar"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["MasterYi"] = function() return self:GotBuff(myHero, "Meditate") == 0 end,
   ["MissFortune"] = function() return self:GotBuff(myHero, "missfortunebulletsound") == 0 end,
   ["Nunu"] = function() return self:GotBuff(myHero, "AbsoluteZero") == 0 end,
   ["Pantheon"] = function() return self:GotBuff(myHero, "") == 0 and self:GotBuff(myHero, "") == 0 end,
   ["TwistedFate"] = function() return self:GotBuff(myHero, "Destiny") == 0 end,
   ["Urgot"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Warwick"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Shen"] = function() return self:GotBuff(myHero, "shenstandunitedlock") == 0 end,
   ["Zac"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Sion"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Xerath"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Ezreal"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Lux"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["VelKoz"] = function() return self:GotBuff(myHero, "VelkozR") == 0 end
   }
   
   self.Channeling2 = {
   ["Gragas"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Lucian"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Vi"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Varus"] = function() return self:GotBuff(myHero, "") == 0 end,
   ["Xerath"] = function() return self:GotBuff(myHero, "") == 0 end,
   }
   
   self.MeleeChamps = {"Camille", "Ivern", "Aatrox", "Akali", "Alistar", "Amumu", "Blitzcrank", "Braum", "Chogath", "Darius", "Diana", "DrMundo", "Ekko", "Elise", "Evelynn", "Fiora", "Fizz", "Galio", "Gangplank", "Garen", "Gnar", "Gragas", "Hecarim", "Illaoi", "Irelia", "Ivern", "JarvanIV", "Jax", "Jayce", "Kassadin", "Katarina", "Kayle", "KhaZix", "Kled", "LeeSin", "Leona", "Malphite", "Maokai", "MasterYi", "Mordekaiser", "Nasus", "Nautilus", "Nidalee", "Nocturne", "Nunu", "Olaf", "Pantheon", "Poppy", "Rammus", "RekSai", "Renekton", "Rengar", "Riven", "Rumble", "Sejuani", "Shaco", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "TahmKench", "Talon", "Taric", "Trundle", "Tryndamere", "Udyr", "Vi", "Volibear", "Warwick", "MonkeyKing", "XinZhao", "Yasuo", "Yorick", "Zac", "Zed"}
   
   self.Structures = {}
   
   self.ClickTarget = nil
   
   self.attacksEnabled = true
   self.movementsEnabled = true
   self.Attacking = false
   self.Moving = false
   self.ForceMove = nil
   self.ForceTarget = nil
   self.LastMovement = 0
   self.LastAttack = 0
   self.ClickDelay = 0.003
   
   Callback.Add("Tick", function() self:Tick() end)
   Callback.Add("Draw", function() self:Draw() end)
   Callback.Add("WndMsg", function(msg, key) self:WndMsg(msg, key) end)
   Callback.Add("Load", function() self:Load() end)
end

function EOW:WndMsg(msg, key)
   if key == 0 and msg == 513 then
      for x = 1, Game.HeroCount() do
         local h = Game.Hero(x)
         if h.isEnemy and not h.dead and mousePos:DistanceTo(h.pos) <= h.boundingRadius * 2 then
            self.ClickTarget = h
            return
         end
      end
      self.ClickTarget = nil
   end
end

function EOW:Load()
   self:MakeMenu()
   for x = 1, Game.ObjectCount() do
      local o = Game.Object(x)
      if o.isEnemy then
         if o.type == Obj_AI_Turret or o.type == Obj_AI_Barracks or o.name:find("HQ_") then
            table.insert(self.Structures, o)
         end
      end
   end
end

function EOW:MakeMenu()

   EOWMenu = MenuElement({id = "EOW", name = "eXternal Orbwalker", type = MENU, leftIcon = "https://i.gyazo.com/817eb6796488c6ff015ea0fc78bdb1ca.png"})
   
   EOWMenu:MenuElement({id = "Config", name = "Settings", type = MENU, leftIcon = "http://www.freeiconspng.com/uploads/settings-icon-2.png"})
   EOWMenu.Config:MenuElement({id = "AE", name = "Attacks Enabled", value = true})
   EOWMenu.Config:MenuElement({id = "ME", name = "Movement Enabled", value = true})
   
   EOWMenu:MenuElement({id = "TS", name = "Target Selector", type = MENU, leftIcon = "https://s.put.re/gmmUvJ6.png"})
   EOWMenu.TS:MenuElement({id = "TSC", name = "Target Selector", value = 1, drop = {"Easiest To Kill", "Closest To You", "Closest To Mouse", "Highest AD", "Highest AP", "Highest HP", "Lowest HP", "Priority"}})
   local Delay = Game.Timer() < 30 and 30 - Game.Timer() or 0
   DelayAction(function()
      for x = 1, Game.HeroCount() do
         local i = Game.Hero(x)
         if i and not i.name:lower():find("dummy") and i.team ~= myHero.team then
            EOWMenu.TS:MenuElement({id = i.networkID, name = "Priority: "..i.charName, value = self:GetPriority(i), min = 1, max = 5, step = 1, leftIcon = "http://ddragon.leagueoflegends.com/cdn/6.24.1/img/champion/"..i.charName..".png"})
         end
      end
   end, Delay)
   
   EOWMenu:MenuElement({id = "Farm", name = "Farm Settings", type = MENU, leftIcon = "https://openclipart.org/image/2400px/svg_to_png/3058/zeimusu-Crossed-swords.png"})
   EOWMenu.Farm:MenuElement({id = "Savagery", name = "Savagery Points", value = 0, min = 0, max = 5, step = 1, leftIcon = "http://www.mobafire.com/images/mastery-s6/savagery.png"})
   EOWMenu.Farm:MenuElement({id = "DES", name = "Double-Edge Sword", value = false, leftIcon = "http://www.mobafire.com/images/mastery-s4/double-edged-sword.png"})
   
   EOWMenu:MenuElement({id = "Humanizer", name = "Humanizer", type = MENU, leftIcon = "https://s.put.re/9a8eB4T.png"})
   EOWMenu.Humanizer:MenuElement({id = "MinMD", name = "Min Movement Delay", value = 50, min = 0, max = 750, step = 1})
   EOWMenu.Humanizer:MenuElement({id = "MaxMD", name = "Max Movement Delay", value = 300, min = 0, max = 750, step = 1})
   EOWMenu.Humanizer:MenuElement({id = "HP", name = "Hold Position", value = 120, min = 0, max = 300, step = 2})
   
   EOWMenu:MenuElement({id = "Draw", name = "Drawings", type = MENU, leftIcon = "http://www.clipartbest.com/cliparts/dc7/o55/dc7o559gi.png"})
   EOWMenu.Draw:MenuElement({id = "DA", name = "Disable All Drawings", value = false})
   
   EOWMenu.Draw:MenuElement({id = "DAA", name = "Draw Auto Attack Range", type = MENU})
   EOWMenu.Draw.DAA:MenuElement({id = "Enabled", name = "Enabled", value = true})
   EOWMenu.Draw.DAA:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
   EOWMenu.Draw.DAA:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
   
   EOWMenu.Draw:MenuElement({id = "DEAA", name = "Draw Enemy Auto Attack Range", type = MENU})
   EOWMenu.Draw.DEAA:MenuElement({id = "Enabled", name = "Enabled", value = true})
   EOWMenu.Draw.DEAA:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
   EOWMenu.Draw.DEAA:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
   
   EOWMenu.Draw:MenuElement({id = "DT", name = "Draw Selected Target", type = MENU})
   EOWMenu.Draw.DT:MenuElement({id = "Enabled", name = "Enabled", value = true})
   EOWMenu.Draw.DT:MenuElement({id = "Width", name = "Width", value = 3, min = 1, max = 5, step = 1})
   EOWMenu.Draw.DT:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 0, 0)})
   
   EOWMenu.Draw:MenuElement({id = "DLH", name = "Draw LastHit", type = MENU})
   EOWMenu.Draw.DLH:MenuElement({id = "Enabled", name = "Enabled", value = true})
   EOWMenu.Draw.DLH:MenuElement({id = "Width", name = "Width", value = 3, min = 1, max = 5, step = 1})
   EOWMenu.Draw.DLH:MenuElement({id = "Color", name = "Color", color = Draw.Color(255, 255, 255, 255)})
   
   EOWMenu:MenuElement({id = "Keys", name = "Keys", type = MENU, leftIcon = "https://s29.postimg.org/q3l24fyaf/680365ba69.png"})
   EOWMenu.Keys:MenuElement({id = "CK", name = "Combo Key", key = string.byte(" ")})
   EOWMenu.Keys:MenuElement({id = "HK", name = "Harass Key", key = string.byte("C")})
   EOWMenu.Keys:MenuElement({id = "LCK", name = "LaneClear Key", key = string.byte("V")})
   EOWMenu.Keys:MenuElement({id = "LHK", name = "LastHit Key", key = string.byte("X")})

end

function EOW:Tick()
   self.attacksEnabled = EOWMenu.Config.AE:Value()
   self.movementsEnabled = EOWMenu.Config.ME:Value()
   
   if self:Mode() ~= "" then
      self:Attack()
      self:Move()
   end
end

function EOW:Draw()
   if EOWMenu.Draw.DA:Value() or myHero.dead then
      return
   end
   
   if EOWMenu.Draw.DAA.Enabled:Value() and not myHero.dead then
      Draw.Circle(myHero.pos, self:Range(myHero), EOWMenu.Draw.DAA.Width:Value(), EOWMenu.Draw.DAA.Color:Value())
   end
   
   --[[if EOWMenu.Draw.DLH.Enabled:Value() then
      local m = self:GetLastHit()
      if m then
         Draw.Circle(m.pos, m.boundingRadius, EOWMenu.Draw.DLH.Width:Value(), EOWMenu.Draw.DLH.Color:Value())
      end
   end]]
   
   if EOWMenu.Draw.DT.Enabled:Value() and self.ClickTarget and not self.ClickTarget.dead and self.ClickTarget.visible then 
      Draw.Circle(self.ClickTarget.pos, self.ClickTarget.boundingRadius, EOWMenu.Draw.DT.Width:Value(), EOWMenu.Draw.DT.Color:Value())
   end
end

function EOW:Attack()
   if not self.attacksEnabled then
      return
   end
   
   local Target = self:GetOrbTarget()
   if Target and self:CanOrb(Target) and self:CanAttack() then
      Order:Attack(Target)
   end
end

function EOW:GetAttackDelayOffsetPercent(unit)
   --soontm :pepo:
end

function EOW:GetAttackDelayCastOffsetPercent(unit)
   --soontm :pepo:
end

function EOW:GetWindUp(unit)
   return unit.attackData.windUpTime
end

function EOW:GetAnimationTime(unit)
   return unit.attackData.animationTime
end

function EOW:GetWindDown(unit)
   local AD = unit.attackData
   return math.max(AD.animationTime - AD.windUpTime, AD.windDownTime)
end

function EOW:GetOrbTarget()
   if self:Mode() == "Combo" then
      return self:GetTarget()
   elseif self:Mode() == "Harass" then
      return self:GetLastHit() or self:GetTarget()
   elseif self:Mode() == "LastHit" then
      return self:GetLastHit()
   elseif self:Mode() == "LaneClear" then
      return self:GetLastHit() or self:GetJungleClear() or self:GetStructure() or self:GetLaneclear()
   end
end

function EOW:GetTarget()
   return self:CanOrb(self.ClickTarget) and self.ClickTarget or self.TargetSelector[EOWMenu.TS.TSC:Value()]()
end

function EOW:GetLastHit()
   for x = 1, Game.MinionCount() do
      local m = Game.Minion(x)
      if m.isEnemy and self:CanOrb(m) then
         local PS = self:GetProjectileSpeed(myHero)
         local Dis = myHero.pos:DistanceTo(m.pos)
         local hp = self:PredictHealth(m, self:GetWindUp(myHero) + (Dis/PS))
         if hp > 0 and hp <= self:GetDamage(myHero, m) then
            self.LastHit = m
            return m
         end
      end
   end
end

function EOW:GetJungleClear()
   local highest = 0
   local best = nil
   for x = 1, Game.MinionCount() do
      local j = Game.Minion(x)
      if j.team == 300 and self:CanOrb(j) then
         if self:GetDamage(myHero, j) >= j.health then
            return j
         end 
         if j.maxHealth > highest then
            highest = j.maxHealth
            best = j
         end
      end
   end
   return best
end   

function EOW:GetStructure()
   for _, s in pairs(self.Structures) do
      if not s.dead then
         if self:CanOrb(s) then
            return s
         end
      else
         table.remove(self.Structures, _)
      end
   end
end

function EOW:GetLaneclear()
   local b = nil
   for x = 1, Game.MinionCount() do
      local m = Game.Minion(x)
      if m.isEnemy and self:CanOrb(m) then
         local PS = self:GetProjectileSpeed(myHero)
         local PredHP = self:PredictHealth(m, (self:GetWindUp(myHero) + self:GetAnimationTime(myHero)) + (m.distance/PS))
         local Damage = self:GetDamage(myHero, m)
         if PredHP ~= m.health and PredHP - Damage <= Damage then
            return nil
         else
            b = self:GetHighestMinion()
         end
      end
   end
   return b
end

function EOW:GetHighestMinion()
   local Best = nil
   local Highest = 0
   for x = 1, Game.MinionCount() do
      local m = Game.Minion(x)
      if m.isEnemy and self:CanOrb(m) and m.maxHealth > Highest then
         Best = m
         Highest = m.maxHealth
      end
   end
   return Best
end

function EOW:AttacksEnabled(bool)
   EOWMenu.Config.AE:Value(bool)
   self.attacksEnabled = bool
end   

function EOW:MovementsEnabled(bool)
   EOWMenu.Config.ME:Value(bool)
   self.movementsEnabled = bool
end

function EOW:IsMelee(champ)
   return self:TableContains(self.MeleeChamps, champ.charName) 
end

function EOW:TableContains(tabel, thing)
   for _, i in pairs(tabel) do
      if i == thing or _ == thing then
         return true
      end
   end
   return false
end

function EOW:GetProjectileSpeed(champ)
   local SP = self.SpecialProjectiles[champ.charName]
   local SP2 = self.SpecialProjectiles2[champ.charName]
   if SP then
      if self:GotBuff(champ, SP.name) > 0 then
         return SP.speed
      end
   elseif SP2 then
      if champ:GetSpellData(_Q).name == SP2.name then
         return SP2.speed
      end
   end
   return self:IsMelee(champ) and math.huge or champ.attackData.projectileSpeed
end

function EOW:PredictHealth(unit, delta)
   if unit == nil or unit.dead then 
      return 0
   end
   
   if unit.type ~= Obj_AI_Minion then
      return unit.health
   end
   
   local Damage = 0
   local Handle = unit.handle
   delta = delta - (Game.Latency() / 1000) - (self.ClickDelay)
   
   for x = 1, Game.MinionCount() do
      local source = Game.Minion(x)
      if source.team ~= unit.team then
         local ad = source.attackData
         local ps = ad.projectileSpeed
         if source.charName:find("Melee") or source.charName:find("Siege") then
            ps = math.huge 
         end
         if not source.dead and not unit.dead and ad.endTime > 0 and ad.target == Handle then
            local WindUp = self:GetWindUp(source)
            local AnimationTime = self:GetAnimationTime(source)
            local Distance = source.pos:DistanceTo(unit.pos)
            local TravelTime = Distance / ps
            local AttackStartTime = ad.endTime - AnimationTime
            local TimeToHit = WindUp + TravelTime
            local TimeWillHit = AttackStartTime + TimeToHit
            local ReAttackTime = AnimationTime + WindUp + TravelTime
            if TimeWillHit < Game.Timer() then
               if AttackStartTime + ReAttackTime - delta < Game.Timer() then
                  Damage = Damage + self:GetDamage(source, unit)
               end   
            elseif TimeWillHit - delta < Game.Timer() then
               Damage = Damage + self:GetDamage(source, unit)
            end
            if Damage > unit.health then
               return unit.health - Damage
            end
         end
      end
   end
   
   local NetwerkID = unit.networkID
   
   for x = 1, Game.TurretCount() do
      local source = Game.Turret(x)
      if source.team ~= unit.team then
         local ad = source.attackData
         local ps = ad.projectileSpeed
         if not source.dead and not unit.dead and ad.endTime > 0 and source.targetID == NetwerkID then
            local WindUp = self:GetWindUp(source)
            local AnimationTime = self:GetAnimationTime(source)
            local Distance = source.pos:DistanceTo(unit.pos)
            local TravelTime = Distance / ps
            local AttackStartTime = ad.endTime - AnimationTime
            local TimeToHit = WindUp + TravelTime
            local TimeWillHit = AttackStartTime + TimeToHit
            local ReAttackTime = AnimationTime + WindUp + TravelTime
            if TimeWillHit < Game.Timer() then
               if AttackStartTime + ReAttackTime - delta < Game.Timer() then
                  Damage = Damage + self:GetDamage(source, unit)
               end
            elseif TimeWillHit - delta < Game.Timer() then
               Damage = Damage + self:GetDamage(source, unit)
            end
         end
      end
      if Damage > unit.health then
         return unit.health - Damage
      end
   end
   return unit.health - Damage
end

function EOW:CanAttack()
   if Game.Timer() >= myHero.attackData.endTime - (self.ClickDelay) - (Game.Latency()/1000) - 0.1 and self.attacksEnabled then
      if myHero.charName == "Graves" or myHero.charName == "Jhin" then
         return myHero.hudAmmo > 0
      end
      return true
   end
end

function EOW:Move()
   if not self:CanMove() then
      return
   end
   
   local Max = EOWMenu.Humanizer.MaxMD:Value()
   local Min = math.min(EOWMenu.Humanizer.MinMD:Value(), Max)
   
   if GetTickCount() >= self.LastMovement + math.random(Min, Max) then
      Order:Move()
      self.LastMovement = GetTickCount()
   end
end

function EOW:CanMove()
   if mousePos:DistanceTo(myHero.pos) > EOWMenu.Humanizer.HP:Value() and self.movementsEnabled then
      local WindDown = self:GetWindDown(myHero)
      if myHero.charName == "Kalista" or myHero.charName == "Graves" then
         return true
      end
      return Game.Timer() >= myHero.attackData.endTime - WindDown - self.ClickDelay - (Game.Latency() / 1000)
   end
end

function EOW:Mode()
   if EOWMenu.Keys.CK:Value() then
      return "Combo"
   elseif EOWMenu.Keys.HK:Value() then
      return "Harass"
   elseif EOWMenu.Keys.LHK:Value() then
      return "LastHit"
   else
      return EOWMenu.Keys.LCK:Value() and "LaneClear" or ""
   end
end

function EOW:CanOrb(unit)
   return unit and unit.team ~= myHero.team and unit.distance <= myHero.range + (myHero.boundingRadius * 0.5) + (unit.boundingRadius * 0.5) and not unit.dead and unit.isTargetable and unit.visible
end

function EOW:ValidTarget(unit, range)
   range = range or math.huge
   return unit.distance <= range and unit.isTargetable and not unit.dead and unit.valid and unit.visible
end

function EOW:GetDamage(source, target)

   if target == nil or source == nil or source.dead or target.dead then
      return 0
   end
   
   if target.type == Obj_AI_Minion then
      if target.maxHealth <= 6 then
         return 1
      elseif source.type == Obj_AI_Minion then
         return math.floor(source.totalDamage * (1 + source.bonusDamagePercent) - target.flatDamageReduction)
      elseif source.type == Obj_AI_Turret and Game.mapID == 11 and self.MinionDamage[target.charName] then
         return math.floor(target.maxHealth * self.MinionDamage[target.charName])
      end
   end
   
   local ADDmg = source.totalDamage
   local APDmg = 0
   local TRUEDmg = 0
   local critDamage = 2
   local critChance = source.critChance
   local Hero = Obj_AI_Hero
   local Minion = Obj_AI_Minion
   local Turret = Obj_AI_Turret
   
   if source.isMe and target.type ~= Turret then
      
      local Items = {}
      for x = ITEM_1, ITEM_7 do
         local ItemID = source:GetItemData(x).itemID
         if ItemID > 0 then
            Items[ItemID] = true
         end
      end
      
      self.SourceBuffs = {}
      self.TargetBuffs = {}
      
      for x = 0, 63 do
         local sb = source:GetBuff(x)
         if sb and sb.name ~= "" and sb.count > 0 then
            self.SourceBuffs[sb.name] = sb.count
         end
         local tb = target:GetBuff(x)
         if tb and tb.name ~= "" and tb.count > 0 then
            self.TargetBuffs[tb.name] = tb.count
         end
      end
      
      if source.charName == "Jhin" and self.SourceBuffs["jhinpassiveattackbuff"] then
         critChance = 1
      elseif source.charName == "Pantheon" and source:GetSpellData(_E).level > 0 and self:GetPercentHP(target) < 15 then
         critChance = 1
      elseif source.charName == "Ashe" or source.charName == "Graves" then
         critChance = 0
      end
      
      if critChance == 1 then
         if Items[3031] then
            critDamage = critDamage + 0.5
         end
         if source.charName == "Yasuo" then
            critDamage = critDamage - 0.1
         elseif source.charName == "Jhin" then
            critDamage = critDamage - 0.25
         end   
         ADDmg = ADDmg * critDamage
      end   
      
      if self.SourceBuffs["itemstatikshankcharge"] == 100 then
         --Statikk Shiv
         if Items[3087] then
            if target.type ~= Minion then
               APDmg = (critChance == 1 and (({50,50,50,50,50,56,61,67,72,77,83,88,84,99,104,110,115,120})[source.levelData.lvl] * critDamage) or ({50,50,50,50,50,56,61,67,72,77,83,88,84,99,104,110,115,120})[source.levelData.lvl])
            else
               APDmg = APDmg + (critChance == 1 and (({110,110,110,110,110,123.2,134.2,147.4,158.4,169.4,182.6,193.6,206.8,217.8,228.8,242,253,264})[source.levelData.lvl] * critDamage) or ({110,110,110,110,110,123.2,134.2,147.4,158.4,169.4,182.6,193.6,206.8,217.8,228.8,242,253,264})[source.levelData.lvl])
            end
         --RapidFire Cannon
         elseif Items[3094] then
            APDmg = APDmg + ({50,50,50,50,50,58,66,75,83,92,100,109,117,126,134,143,151,160})[source.levelData.lvl]
         --Kircheis Shard
         elseif Items[2015] then
            APDmg = APDmg + 40
         end
      end      
      
      if self.bonusDamageTable[source.charName] then
         ADDmg, APDmg, TRUEDmg = self.bonusDamageTable[source.charName](source, target, ADDmg, APDmg, TRUEDmg, self.SourceBuffs, self.TargetBuffs)
      end
      
      --BORK
      --[[if self:GetItemSlot(source, 3153) > 0 then
         ADDmg = ADDmg + (target.isMinion and math.max(math.min(60, 0.08 * self:PredHP(target, self:GetWindUp(myHero) + (GetDistance(source, target) / self:PSpeed(myHero)))), 10) or 0.08 * target.health)
      end]]
      
      --BloodRazor
      if Items[1419] or Items[1418] or Items[1416] then
         ADDmg = ADDmg + (target.type == Minion and math.min(75, target.maxHealth * 0.04) or (target.maxHealth*0.04))
      end
      
      --Runaan's
      if source.range > 350 and Items[3085] then
         ADDmg = ADDmg + 15
      end   
      
      --Recurve Bow
      if Items[1043] then
         ADDmg = ADDmg + 15
      end
         
      --Nashor's Tooth  
      if Items[3115] then
         APDmg = APDmg + 15 + (source.ap * 0.15)
      end

      --Wit's End
      if Items[3091] then
         APDmg = APDmg + 40
      end
   
      --Guinsoo's
      if Items[3124] then
         APDmg = APDmg + 15
      end
      
      --Titanic Hydra
      if source.range <= 350 and Items[3748] then
         ADDmg = ADDmg + 5 + (source.maxHealth * 0.01)
      end
      
      --Savagery Mastery
      --[[if target.type == Minion then
         TRUEDmg = TRUEDmg + EOWMenu.Farm.Savagery:Value()
      end
      
      --Double-Edge Sword Mastery
      if EOWMenu.Farm.DES:Value() then
         ADDmg = ADDmg + (ADDmg*0.05)
         APDmg = APDmg + (APDmg*0.05)
         TRUEDmg = TRUEDmg + (TRUEDmg*0.05)
      end   ]]
   
      --add triforce
      if self.SourceBuffs["sheen"] then 
         if Items[3057] then
            ADDmg = ADDmg + source.baseDamage
         elseif Items[3078] then
            ADDmg = ADDmg + (2 * source.baseDamage)
         end
      end
      
      if self.SourceBuffs["itemfrozenfist"] then
         ADDmg = ADDmg + source.baseDamage
      end
         
      if self.SourceBuffs["lichbane"] then
         APDmg = APDmg + 0.5 * source.ap
      end
   end
   return self:CalcPhysicalDamage(source, target, ADDmg) + self:CalcMagicalDamage(source, target, APDmg) + math.floor(TRUEDmg)
end

function EOW:CalcPhysicalDamage(source, target, amount)
   local ArmorPenPercent = source.armorPenPercent
   local ArmorPenFlat = source.armorPen * (0.6 + (0.4 * (target.levelData.lvl / 18))) 
   local BonusArmorPen = source.bonusArmorPenPercent
   
   if source.type == Obj_AI_Minion then
      ArmorPenPercent = 1
      ArmorPenFlat = 0
      BonusArmorPen = 1
   elseif source.type == Obj_AI_Turret then
      ArmorPenFlat = 0
      BonusArmorPen = 1
      if source.charName:find("3") or source.charName:find("4") then
         ArmorPenPercent = 0.25
      else
         ArmorPenPercent = 0.7
      end   
      if target.type == Obj_AI_Minion then
         amount = amount * 1.25
         if target.charName:find("MinionSiege") then
            amount = amount * 0.7
         end
         return amount
      end
   end

   local armor = target.armor
   local bonusArmor = target.bonusArmor
   local value = 100 / (100 + (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat)

   if armor < 0 then
      value = 2 - 100 / (100 - armor)
   elseif (armor * ArmorPenPercent) - (bonusArmor * (1 - BonusArmorPen)) - ArmorPenFlat < 0 then
      value = 1
   end
   return math.max(0, math.floor(value * amount))
end

function EOW:CalcMagicalDamage(source, target, amount)
  local mr = target.magicResist
  local value = 100 / (100 + (mr * source.magicPenPercent) - source.magicPen)

  if mr < 0 then
    value = 2 - 100 / (100 - mr)
  elseif (mr * source.magicPenPercent) - source.magicPen < 0 then
    value = 1
  end
  
  return math.max(0, math.floor(value * amount))
end

function EOW:GetItemSlot(unit, id)
   for i = ITEM_1, ITEM_7 do
      if unit:GetItemData(i).itemID == id then
         return i
      end
   end
   return 0
end

function EOW:GetPercentHP(unit)
   return (unit.health / unit.maxHealth) * 100
end

function EOW:GetPercentMP(unit)
   return (unit.mana / unit.maxMana) * 100
end

function EOW:GotBuff(unit, buff)
   for i = 0, 63 do
      local b = unit:GetBuff(i)
      if buff == b.name then
         return b.count
      end
   end
   return 0
end

function EOW:GetEnemyHeroes()
   local E = {}
   for i = 1, Game.HeroCount() do
      local H = Game.Hero(i)
      if H.isEnemy then
         table.insert(E, H)
      end
   end
   return E
end

function EOW:Range(unit)
   return unit.range + (unit.boundingRadius * 1.5)
end

function EOW:Closest()
   local c = math.huge
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do
      if self:CanOrb(e) and e.distance < c then
         c = e.distance
         t = e
      end
   end
   return t
end

function EOW:ClosestM()
   local c = math.huge
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do
      if self:CanOrb(e) and mousePos:DistanceTo(e.pos) < c then
         c = mousePos:DistanceTo(e.pos)
         t = e
      end
   end
   return t
end

function EOW:HighestAD()
   local c = 0
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do
      if self:CanOrb(e) and e.totalDamage > c then
         c = e.totalDamage
         t = e 
      end
   end
   return t
end

function EOW:HighestAP()
   local c = 0
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do
      if self:CanOrb(e) and e.ap > c then
         c = e.ap
         t = e
      end
   end      
end

function EOW:HighestHP()
   local c = 0
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do 
      if self:CanOrb(e) and e.health > c then
         c = e.health
         t = e 
      end
   end
   return t
end

function EOW:LowestHP()
   local c = math.huge
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do 
      if self:CanOrb(e) and e.health < c then
         c = e.health
         t = e
      end
   end
   return t
end

function EOW:Priority()
   local c = 0
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do 
      if self:CanOrb(e) and EOWMenu.TS[e.networkID]:Value() > c then
         c = EOWMenu.TS[e.networkID]:Value()
         t = e
      end
   end
   return t
end

function EOW:EasyKill()
   local c = math.huge
   local t = nil
   for _, e in pairs(self:GetEnemyHeroes()) do
      local x = e.health / self:GetDamage(myHero, e)
      if self:CanOrb(e) and x < c then
         c = x
         t = e
      end
   end
   return t
end

function EOW:GetPriority(unit)
   for x = 1, #self.P do
      local i = self.P[x]
      if table.contains(i, unit.charName) then
         return x
      end
   end
   return 1
end

_G.Order = Order()
_G.EOW = EOW()
