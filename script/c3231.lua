-- WX22-006 差し伸べし者　タウィル
-- 【常】：あなたのセンタールリグは以下の能力を得る。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード２：あなたのデッキからレベル４以下のシグニ１枚を探して場に出し、デッキをシャッフルする。そのシグニの【出】能力は発動しない。
-- 【起】《ターン１回》《アタックフェイズアイコン》エクシード２：あなたのトラッシュから＜精元＞ではないそれぞれ名前の異なる対象のシグニ７枚をデッキに加えてシャッフルする。この方法で共通するクラスを持つシグニ７枚をデッキに加えた場合、対象の対戦相手のシグニ１体をトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local g1=Effect.CreateEffect(c)
  g1:SetType(EFFECT_TYPE_IGNITION)
  g1:SetDescription(aux.Ability(id,1))
  g1:SetRange(LOCATION_LRIG)
  g1:SetCountLimit(1)
  g1:SetTiming(TIMING_ATTACK)
  g1:SetExceedCost(2)
  g1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(c) return c:IsSigni() and c:GetLevel()<=4 end,1):GetFirst()
    if x then Duel.PutOnField(x,tp,true) end
    aux.ShuffleDeck(tp)
  end)
  local g2=Effect.CreateEffect(c)
  g2:SetType(EFFECT_TYPE_IGNITION)
  g2:SetDescription(aux.Ability(id,2))
  g2:SetRange(LOCATION_LRIG)
  g2:SetCountLimit(1)
  g2:SetTiming(TIMING_ATTACK)
  g2:SetExceedCost(2)
  g2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetSelectCheck(function(sg) local seen={} for x in sg:Iter() do if seen[x:GetCode()] then return false end seen[x:GetCode()]=true end return true end)
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and not x:IsClass(SYS_SEIGEN,0) end,tp,LOCATION_TRASH,0,7,7,nil)
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  g2:SetOperation(function(e,tp)
    local all=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local mine=all:Filter(function(x) return x:IsLocation(LOCATION_TRASH) end,nil)
    local opp=all:Filter(function(x) return x:IsLocation(LOCATION_SZONE) end,nil):GetFirst()
    if mine:GetCount()<7 then return end
    Duel.SendToDeckShuffle(mine,tp)
    if opp and aux.ShareClass(mine) then Duel.SendToTrash(opp,REASON_EFFECT) end
  end)
  -- [の間] 【常】 센터 루리그가 얻는다
  for _,g in ipairs{g1,g2} do
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetDescription(aux.Ability(id,0))
    e1:SetCode(EFFECT_GRANT)
    e1:SetRange(LOCATION_KEY)
    e1:SetTargetRange(LOCATION_LRIG,0)
    e1:SetLabelObject(g)
    c:RegisterEffect(e1)
  end
end
