-- WX12-043 轟炎　フレイスロ少尉
-- 【出】：対戦相手のパワー8000以下のシグニ１体を対象とし、あなたのトラッシュに《小炎　フレイスロ兵長》と《爆炎　フレイスロ軍曹》がある場合、それをバニッシュする。
-- ライフバースト：どちらか１つを選ぶ。①対戦相手のパワー5000以下のシグニ１体を対象とし、それをバニッシュする。②あなたのデッキからカード名に《フレイスロ》を含むシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(aux.BanishPowerTarget(8000))
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return x:IsCardName(2571) end,tp,LOCATION_TRASH,0,nil):GetCount()>0 and Duel.GetMatchingGroup(function(x) return x:IsCardName(2570) end,tp,LOCATION_TRASH,0,nil):GetCount()>0 then Duel.Banish(tc) end end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if e:GetLabel()==0 then Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetPower()<=5000 end,tp,0,LOCATION_SZONE,1,1,nil) end
  end)
  e2:SetOperation(function(e,tp)
    if e:GetLabel()==1 then aux.SearchToHand(tp,function(x) return x:IsSigni() and aux.NameHas(x,"フレイスロ") end,1) return end
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e2)
end
