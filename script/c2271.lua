-- WX08-025 罠砲　タイマーボム
-- 【常】：このシグニはあなたの場にクロス状態のシグニがないかぎり、新たに場に出すことができない。
-- 【自】：あなたのクロス状態のシグニ１体が場を離れたとき、このシグニを場からトラッシュに置く。
-- 【自】：あなたの赤のシグニが《ヘブン》したとき、対戦相手にダメージを与える。
-- ライフバースト：カードを１枚引く。その後、デッキの一番上を公開し、それが《クロスアイコン》を持つシグニの場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_PLAY)
  e1:SetCondition(function(e) local tp=e:GetHandlerPlayer() return not (Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsCross() end,tp,LOCATION_SZONE,0,nil):GetCount()>0) end)
  c:RegisterEffect(e1)
  -- 떠난 시그니가 《クロスアイコン》을 가졌는가로 본다(근사: 떠나기 직전의 크로스 상태)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x~=e:GetHandler() and x:GetOwner()==tp and x:IsSigni() and x:HasCrossIcon() end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.SendToTrash(h,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_HEAVEN)
  e3:SetRange(LOCATION_SZONE)
  e3:SetCondition(function(e,tp,eg,ep) return ep==tp and eg:Filter(function(x) return x:IsColor(COLOR_RED) end,nil):GetCount()>0 end)
  e3:SetOperation(function(e,tp)
    Duel.Damage(1-tp)
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_LIFEBURST)
  e4:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if x:IsSigni() and x:HasCrossIcon() then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e4)
end
