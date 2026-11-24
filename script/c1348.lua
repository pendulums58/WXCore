-- WD22-020-U 堕落の虚無　パイモン
-- 【常】：あなたの＜悪魔＞のシグニ１体がバニッシュされる場合、代わりにそのシグニに付いている【チャーム】１枚をトラッシュに置いてもよい。
-- 【出】：あなたのデッキの一番上のカードをこのシグニの【チャーム】にしてもよい。
-- （【チャーム】は裏向きでシグニに付き、１体に１枚までしか付けられない）
-- ライフバースト：あなたのデッキの上からカードを３枚トラッシュに置く。その後、あなたのトラッシュから＜悪魔＞のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
s.akuma=aux.ClassFilter(0,RACE_AKUMA)  -- ＜悪魔＞のシグニ
function s.initial_effect(c)
  -- [の間] 【常】 배틀·효과·룰 처리 모두(FAQ 1·2)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CHARM_GUARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return s.akuma(x) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local h,top=e:GetHandler(),Duel.GetDecktopGroup(tp,1):GetFirst()
    if top and h:IsLocation(LOCATION_SZONE) and not h:GetCharm() and Duel.SelectYesNo(tp) then Duel.Charm(top,h) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,3)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    local tc=Duel.SelectTarget(tp,s.akuma,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e3)
end
