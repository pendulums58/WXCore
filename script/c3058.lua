-- WX19-034 轟砲　ガトリング
-- 【自】：あなたのセンタールリグがアタックしたとき、このシグニを場からトラッシュに置いてもよい。そうした場合、そのアタックの間、クラッシュされたカードはエナゾーンに置かれる代わりにトラッシュに置かれる。（ライフバーストは発動できる）
local s,id=GetID()
function s.initial_effect(c)
  -- 【自】 「クラッシュされたカードはトラッシュに置かれる」는 아직(이 시그니를 트래시에 두기만. 근사)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and x:IsType(TYPE_LRIG) end)
  e1:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) and Duel.SelectYesNo(tp) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
end
