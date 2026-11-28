-- WXK07-046 羅菌　ビタミンA
-- 【起】《ターン１回》《アタックフェイズアイコン》あなたの場にある【チャーム】１枚をトラッシュに置く：シグニ１体を対象とし、ターン終了時まで、それのパワーを＋2000する。
-- 【起】《ターン１回》《緑×0》：あなたのトラッシュから対象の＜微菌＞のシグニ１枚を対象のあなたの他のシグニ１体の【チャーム】にする。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTiming(TIMING_ATTACK)
  e1:SetCountLimit(1)
  e1:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Group.CreateGroup()
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do if x:GetCharm() then g:AddCard(x:GetCharm()) end end
    if chk==0 then return g:GetCount()>0 end
    Duel.SendToTrash(Duel.SelectCards(tp,g,1,1),REASON_COST)
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,2000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetOperation(function(e,tp,eg)
    local ch=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKIN) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    local host=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x~=e:GetHandler() and not x:GetCharm() end,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if ch and host then Duel.Charm(ch,host) end
  end)
  c:RegisterEffect(e2)
end
