-- WXK01-041 ＭＩＲＡＣＬＥ
-- 以下の３つから１つを選ぶ。
-- ①カードを１枚引く。
-- ②対戦相手は手札を１枚捨てる。
-- ③対戦相手のすべてのシグニを凍結する。
-- 【自】：対戦相手のターン終了時、あなたの手札が０枚の場合、《青》を支払ってもよい。そうした場合、このカードをトラッシュから手札に加える。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) end)
  e1:SetOperation(function(e,tp,eg)
    local m=e:GetLabel()
    if m==0 then Duel.Draw(tp,1)
    elseif m==1 then aux.Discard(1-tp,1)
    else
      -- 처리할 때 장에 있는 것만(FAQ 3)
      for x in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do Duel.Freeze(x) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  -- 루리그와 상관없이(FAQ 1). 트래시에 있어야 한다(FAQ 2)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_TRASH)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()~=tp and Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount()==0 end)
  e2:SetOperation(function(e,tp,eg)
    if not (Duel.CanPayEna(tp,"{U}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{U}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_TRASH) then Duel.SendToHand(h) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
