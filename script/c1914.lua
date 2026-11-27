-- WX02-022 弩砲　ガンスナイプ
-- 【出】《赤》：あなたのシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。
-- 【常】：あなたのライフクロスが３枚以下であるかぎり、あなたの＜ウェポン＞のシグニのパワーを＋2000する。
-- ライフバースト：対戦相手のシグニを、パワーの合計が8000以下になるように好きな数対象とし、それらをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{R}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH) end
  end)
  c:RegisterEffect(e1)
  -- [の間] 【常】
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_UPDATE_POWER)
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_WEAPON)) end)(x) end)
  e2:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_LIFE,0,nil):GetCount()<=3 end)
  e2:SetValue(2000)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  -- 고를 때의 파워 합계(FAQ 1)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(g)
      local n=0
      for x in g:Iter() do n=n+x:GetPower() end
      return n<=8000
    end)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,0,3,nil)
  end)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    if g:GetCount()>0 then Duel.Banish(g) end
  end)
  c:RegisterEffect(e3)
end
