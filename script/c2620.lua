-- WX13-049 羅原　Ｌｉ
-- 【常】：あなたのトラッシュにスペルが３枚以上あるかぎり、このシグニは対戦相手の効果によってバニッシュされない。
-- 【自】：このシグニがアタックしたとき、あなたのトラッシュからスペル１枚を対象とし、あなたのトラッシュに＜原子＞のシグニが７種類以上ある場合、それを手札に加える。
-- ライフバースト：あなたのデッキから＜原子＞のシグニ１枚かスペル１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_BANISH_IMMUNE)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_SPELL) end,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=3 end)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsType(TYPE_SPELL) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then local seen,n={},0 for x in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end,tp,LOCATION_TRASH,0,nil):Iter() do if not seen[x:GetCode()] then seen[x:GetCode()]=true n=n+1 end end
        if n>=7 then Duel.SendToHand(tc) end end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    aux.SearchToHand(tp,function(x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_GENSHI)) end)(x) or x:IsType(TYPE_SPELL) end,1)
  end)
  c:RegisterEffect(e3)
end
