-- WXK10-053 羅星　タイマーボム
-- 【常】：対戦相手のレベル１以下のシグニがバニッシュされる場合、エナゾーンに置かれる代わりにトラッシュに置かれる。
-- 【起】《ターン１回》《黒》：あなたのデッキの一番上を公開する。その後、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのレベルをこの方法で公開されたシグニのレベルと同じだけ－（マイナス）する。公開したカードを手札に加える。（レベルは０未満にはならない）
-- ライフバースト：あなたのセンタールリグと同じレベルの対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_TO_TRASH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,LOCATION_SZONE)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:GetLevel()<=1 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{B}")
  e2:SetOperation(function(e,tp,eg)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    local n=x:IsSigni() and x:GetLevel() or 0
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc and n>0 then
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_UPDATE_LEVEL)
      e1:SetValue(-math.min(n,tc:GetLevel()))
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
    Duel.SendToHand(x)
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local lv=lc and lc:GetLevel() or -1
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==lv end,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToTrash(tc,REASON_EFFECT)
    end
  end)
  c:RegisterEffect(e9)
end
