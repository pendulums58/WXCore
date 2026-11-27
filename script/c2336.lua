-- WX09-010 白鎧亜　ロートレット
-- 【出現条件】 《メインフェイズアイコン》《甲冑　ローメイル》１体と《篭手　トレット》１体をあなたの場からトラッシュに置く
-- 【常】：あなたのシグニのパワーを＋1000する。
-- 【自】：このシグニがバニッシュされたとき、あなたのデッキから《篭手　トレット》１枚を探して場に出し、デッキをシャッフルする。
-- 【出】：あなたのデッキからカード１枚を探して手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and (x:IsCardName(410) or x:IsCardName(412)) end,nil,nil,nil,function(g) return g:Filter(function(x) return x:IsCardName(410) end,nil):GetCount()>=1 and g:Filter(function(x) return x:IsCardName(412) end,nil):GetCount()>=1 end)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() end)
  e1:SetValue(1000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_BANISHED)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return c:IsCardName(412) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local x=aux.Search(tp,nil,1)
    if x:GetCount()>0 then Duel.SendToHand(x) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
