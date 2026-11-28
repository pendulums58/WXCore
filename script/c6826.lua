-- WXK08-040 ウォーター・ボンバー
-- 以下の３つから２つまで選ぶ。
-- ①あなたのデッキからシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ②対戦相手のシグニ１体を対象とし、それを手札に戻す。
-- ③あなたの登録者数が１００万人を達成している場合、このスペルを手札に戻す。
-- ライフバースト：あなたのデッキから＜電機＞のシグニ１枚を探して公開し手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    for _,m in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==0 then aux.SearchToHand(tp,Card.IsSigni,1)
      elseif m==1 then
        local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
        if tc then Duel.SendToHand(tc) end
      elseif Duel.GetSubscribers(tp)>=100 then
        local me=e:GetHandler()
        if me:IsLocation(LOCATION_CHECK) then Duel.SendToHand(me) end
      end
    end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    local x=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) end,1):GetFirst()
    if x then
      if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then Duel.SendToHand(x) else Duel.PutOnField(x,tp) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e9)
end
