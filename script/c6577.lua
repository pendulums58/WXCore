-- WXK05-035 極装　オニマル
-- 【ライズ】あなたの＜アーム＞のシグニ１体にエナゾーンとトラッシュにある＜アーム＞のシグニ１枚ずつを重ね、その上に置く
-- 【常】：このシグニの下にレベル４のシグニが３枚あるかぎり、このシグニのパワーは＋2000され、このシグニは対戦相手のルリグの効果を受けない。
-- 【出】：対戦相手のシグニ１体を対象とし、このシグニの下にレベル１、レベル２、レベル３のシグニがある場合、それをバニッシュする。
-- ライフバースト：手札を２枚捨て、カードを３枚引く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【ライズ】(근사: ＜アーム＞ 시그니 1체 위. 에나·트래시의 ＜アーム＞를 겹치는 것은 아직)
  aux.AddRise(c,function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return e:GetHandler():GetUnderGroup():Filter(function(x) return x:IsSigni() and x:GetLevel()==4 end,nil):GetCount()>=3 end)
  e1:SetValue(2000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EFFECT_IMMUNE)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e) return e:GetHandler():GetUnderGroup():Filter(function(x) return x:IsSigni() and x:GetLevel()==4 end,nil):GetCount()>=3 end)
  e2:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsType(TYPE_LRIG) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e3:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local u=e:GetHandler():GetUnderGroup()
      local ok=true
      for lv=1,3 do if u:Filter(function(x) return x:IsSigni() and x:GetLevel()==lv end,nil):GetCount()==0 then ok=false end end
      if ok then Duel.Banish(tc) end
    end
  end)
  c:RegisterEffect(e3)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    aux.Discard(tp,2)
    Duel.Draw(tp,3)
  end)
  c:RegisterEffect(e9)
end
