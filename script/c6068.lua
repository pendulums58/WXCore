-- WXEX1-34 幻竜姫　レッドドラゴン
-- 【自】：このシグニがアタックしたとき、対戦相手は《無》《無》《無》を支払ってもよい。そうしなかった場合、ターン終了時まで、あなたのすべての＜龍獣＞のシグニは【アサシン】を得る。
-- 【出】《赤》《無》：対戦相手は自分のエナゾーンからカード１枚を対象とし、それをトラッシュに置く。
-- 【起】《ターン１回》《緑》：あなたのエナゾーンから《幻竜姫　レッドドラゴン》以外の＜龍獣＞のシグニを２枚まで対象とし、それらを手札に加える。
-- ライフバースト：対戦相手のパワー12000以下のシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp)
    local paid=false
    if Duel.CanPayEna(1-tp,"{C}{C}{C}") and Duel.SelectYesNo(1-tp) then
      local g=Duel.SelectEnaCost(1-tp,"{C}{C}{C}")
      paid=g:GetCount()>0 and Duel.SendToTrash(g,REASON_COST)>0
    end
    if not paid then
      -- [まで] ターン終了時まで、あなたのすべての＜龍獣＞のシグニは【アサシン】を得る
      for x in Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_RYUJU),tp,LOCATION_SZONE,0,nil):Iter() do
        aux.GrantKeyword(e,x,EFFECT_ASSASSIN)
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{R}{C}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(1-tp,nil,1-tp,LOCATION_ENA,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_SZONE)
  e3:SetCountLimit(1)
  e3:SetEnaCost("{G}")
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_RYUJU) and not x:IsCardName(id) end,tp,LOCATION_ENA,0,0,2,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(Card.IsRelateToEffect,nil,e)
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(aux.BanishPowerTarget(12000))
  e9:SetOperation(aux.BanishOp)
  c:RegisterEffect(e9)
end
