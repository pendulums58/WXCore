-- WD23-001-E エルドラ×マークⅣ　アナザー
-- 【常】：あなたの手札の枚数の上限は１増える。（６枚から７枚になる）
-- 【出】：あなたのルリグデッキから＜水獣＞のレゾナ１枚を出現条件を無視して場に出す。
-- 【起】《ターン１回》エクシード１：あなたのデッキからレベルの異なる＜水獣＞のシグニ２枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
s.suiju=aux.ClassFilter(0,RACE_SUIJU)  -- ＜水獣＞のシグニ
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_HAND_LIMIT)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  e1:SetValue(1)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- 루리그 덱은 비공개라 내지 않아도 된다(FAQ 2)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_RESONA) and x:IsClass(0,RACE_SUIJU) end,tp,LOCATION_LDECK,0,nil)
    local tc=Duel.SelectCards(tp,g,0,1):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1)
  e3:SetExceedCost(1)
  -- 2장을 다 낼 수 없으면 1장도 내지 않는다(FAQ 3·4)
  e3:SetOperation(function(e,tp)
    Duel.SetSelectCheck(function(g) return g:GetCount()==0 or (g:GetCount()==2 and aux.DistinctLevels(g) and Duel.CanPutAll(g,tp)) end)
    for tc in aux.Search(tp,s.suiju,2):Iter() do Duel.PutOnField(tc,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
