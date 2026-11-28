-- PR-K073 コードＶＬ　花畑チャイカ（カードゲーマー vol.50 付録）
-- 【出】：あなたの場にレベル２、レベル３、レベル４のシグニがある場合、以下の２つから１つを選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－8000する。
-- ②あなたのデッキから《コードＶＬ　花畑チャイカ》以外の＜電機＞のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
-- ライフバースト：あなたのトラッシュからレベル２の＜電機＞のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local have={}
    for x in Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil):Iter() do have[x:GetLevel()]=true end
    if not (have[2] and have[3] and have[4]) then return end
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-8000) end  -- [まで] ターン終了時まで
    else
      local g=aux.Search(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_DENKI) and not x:IsCardName(id) end,1)
      if g:GetCount()>0 then
        Duel.RevealCards(g)
        Duel.SendToHand(g)
      end
      aux.ShuffleDeck(tp)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==2 and x:IsClass(0,RACE_DENKI) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
end
