-- WX12-015 緑幻竜　＃ティラザウス＃
-- 【出現条件】《メインフェイズアイコン》赤の＜龍獣＞のシグニ１枚と緑の＜龍獣＞のシグニ１枚をあなたのエナゾーンからトラッシュに置く
-- 【自】：このシグニが場から離れたとき、あなたのデッキからカード名に《幻竜姫》を含むシグニ１枚を探して場に出し、デッキをシャッフルする。
-- 【出】：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。
-- 【出】：対戦相手のパワー15000以上のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and (x:IsClass(0,RACE_RYUJU)) end,LOCATION_ENA,nil,nil,function(g)
    local r,gr=false,false
    for x in g:Iter() do
      if x:IsColor(COLOR_RED) and not r then r=true elseif x:IsColor(COLOR_GREEN) then gr=true end
    end
    return r and gr
  end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_LEAVE_FIELD)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return c:IsSigni() and aux.NameHas(c,"幻竜姫") end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetTarget(aux.BanishPowerTarget(10000))
  e2:SetOperation(aux.BanishOp)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()>=15000 end,tp,0,LOCATION_SZONE,1,1,nil) end)
  e3:SetOperation(aux.BanishOp)
  c:RegisterEffect(e3)
end
