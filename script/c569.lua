-- WX04-029 コードラビリンス　クイン
-- 【自】：対戦相手のシグニ１体がアタックしたとき、ターン終了時まで、あなたのすべての＜迷宮＞のシグニのパワーを＋1000する。その後、アタックしたシグニの正面にシグニがない場合、このシグニをアタックしたシグニの正面に配置してもよい。
-- ライフバースト：あなたのデッキから＜迷宮＞のシグニ１枚を探して公開し、手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()~=tp end)
  e1:SetOperation(function(e,tp,eg)
    for tc in Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end,tp,LOCATION_SZONE,0,nil):Iter() do aux.AddPower(e,tc,1000) end  -- [まで] ターン終了時まで
    local a,h=eg:GetFirst(),e:GetHandler()
    if not (a:IsLocation(LOCATION_SZONE) and h:IsLocation(LOCATION_SIGNI)) or a:GetFrontCard() then return end
    local z=Duel.GetFrontZone(a:GetZone())
    if z and Duel.SelectYesNo(tp) then Duel.MoveSigni(h,z) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  -- 존이 없으면 패에 넣는다(FAQ 2)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_MEIKYU)) end,1):GetFirst()
    if x then
      Duel.RevealCards(x)
      if not (Duel.SelectYesNo(tp) and Duel.PutOnField(x,tp)) then Duel.SendToHand(x) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
