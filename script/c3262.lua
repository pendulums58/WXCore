-- WX22-041 催事の誘導　イベントポップ
-- 【出】：あなたのデッキの一番上を公開する。それがレベル２以上の＜美巧＞のシグニの場合、それを手札に加える。
-- 【起】《白》《ダウン》手札から＜美巧＞のシグニを１枚捨てる：この方法で捨てたシグニと同じレベルの対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if (function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end)(x) and x:GetLevel()>=2 then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetEnaCost("{W}")
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_BIKOU)) end,tp,LOCATION_HAND,0,nil)
    if chk==0 then return e:GetHandler():IsUp() and g:GetCount()>0 end
    Duel.Down(e:GetHandler(),REASON_COST)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    e:SetLabel(x:GetLevel())
    Duel.SendToTrash(x,REASON_COST+REASON_DISCARD)
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
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
  end)
  c:RegisterEffect(e3)
end
