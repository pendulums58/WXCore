-- WX02-023 幻水姫　スパイラル・カーミラ
-- 【出】《青》：カードを１枚引く。
-- 【常】：あなたの手札が対戦相手より２枚以上多いかぎり、あなたの＜水獣＞のシグニのパワーを＋2000する。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手の手札を１枚見ないで選び、捨てさせる。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}")
  e1:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e1)
  -- 2체면 각각(FAQ 1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(x) end)
  e2:SetCondition(function(e) local p=e:GetHandlerPlayer() return Duel.GetMatchingGroup(nil,p,LOCATION_HAND,0,nil):GetCount()-Duel.GetMatchingGroup(nil,p,0,LOCATION_HAND,nil):GetCount()>=2 end)
  e2:SetValue(2000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1)))
    
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then
      Duel.Draw(tp,1)
      return
    end
    local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if g:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT+REASON_DISCARD) end
  end)
  c:RegisterEffect(e3)
end
