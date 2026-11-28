-- WXEX1-57 天界の異端　マスティマ
-- 【出】：あなたのデッキの一番上を公開する。それが白か黒の＜天使＞のシグニの場合、それを手札に加える。
-- 【起】《ターン１回》《白》他の＜天使＞のシグニ１体を場からトラッシュに置く：この方法でトラッシュに置いたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:IsClass(0,RACE_TENSHI) and (x:IsColor(COLOR_WHITE) or x:IsColor(COLOR_BLACK)) then
      Duel.SendToHand(x)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{W}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local pool=Duel.GetMatchingGroup(aux.ClassFilter(0,RACE_TENSHI),tp,LOCATION_SZONE,0,e:GetHandler())
    if chk==0 then return pool:GetCount()>0 end
    local x=Duel.SelectCards(tp,pool,1,1):GetFirst()
    if x then
      e:SetLabel(x:GetLevel())
      Duel.SendToTrash(x,REASON_COST)
    end
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lv=e:GetLabel()
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(aux.EnaChargeOp(1))
  c:RegisterEffect(e9)
end
