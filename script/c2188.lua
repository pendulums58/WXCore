-- WX07-017 台風一過
-- 各プレイヤーは、自分の手札とエナゾーンにあるカードと場にあるシグニをすべてトラッシュに置く。その後、各プレイヤーは自分のトラッシュからシグニを３枚まで対象とし、それらを場に出す。その後、各プレイヤーは自分のトラッシュからシグニを３枚まで対象とし、それらを手札に加える。その後、対戦相手は自分のトラッシュからカードを３枚まで対象とし、それらをエナゾーンに置く。（あなたからカードを選択し両者が同時に移動させる。トリガーした能力はこのアーツの後に、あなたから好きな順番で処理する）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 「あなたから」 고른다. 동시에 옮긴다
  e1:SetOperation(function(e,tp)
    for _,p in ipairs({tp,1-tp}) do
      local g=Duel.GetMatchingGroup(nil,p,LOCATION_HAND+LOCATION_ENA,0,nil)
      g:Merge(Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil))
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
    local picks={}
    for _,p in ipairs({tp,1-tp}) do picks[p]=Duel.SelectCards(p,Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_TRASH,0,nil),0,3) end
    for _,p in ipairs({tp,1-tp}) do for x in picks[p]:Iter() do Duel.PutOnField(x,p) end end
    for _,p in ipairs({tp,1-tp}) do picks[p]=Duel.SelectCards(p,Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_TRASH,0,nil),0,3) end
    for _,p in ipairs({tp,1-tp}) do if picks[p]:GetCount()>0 then Duel.SendToHand(picks[p]) end end
    local en=Duel.SelectCards(1-tp,Duel.GetMatchingGroup(nil,1-tp,LOCATION_TRASH,0,nil),0,3)
    if en:GetCount()>0 then Duel.SendToEna(en) end
  end)
  c:RegisterEffect(e1)
end
