-- WD16-011 コードハート　Ｖ・Ａ・Ｃ
-- 【常】：あなたが使用する青のスペルのコストは《無×1》減る。
-- 【出】《青》：対戦相手は手札を１枚捨てる。
-- 【起】《青》《青》：あなたのトラッシュからスペル１枚を対象とし、それを手札に加える。
-- ライフバースト：対戦相手は手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 여러 체면 겹친다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_REDUCE_COST)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(1,0)
  e1:SetTarget(function(e,c) return c:IsType(TYPE_SPELL) and c:IsColor(COLOR_BLUE) end)
  e1:SetEnaCost("{C}")
  e1:SetValue(1)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{U}")
  e2:SetOperation(function(e,tp) s.disc(1-tp,1) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetEnaCost("{U}{U}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp) s.disc(1-tp,1) end)
  c:RegisterEffect(e4)
end
-- 「手札をＮ枚捨てる」: 모자라면 있는 만큼
function s.disc(p,n)
  n=math.min(n,Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount())
  if n>0 then Duel.SendToTrash(Duel.SelectDiscard(p,n,n),REASON_EFFECT+REASON_DISCARD) end
end
