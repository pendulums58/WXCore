-- WXK09-091 星銀の童話　ハイリム
-- 【出】：あなたのトラッシュから対象の＜美巧＞のシグニ３枚をデッキに加えてシャッフルする。この方法で《星銀の童話　バズイール》と《星銀の童話　ブロト》をデッキに加えた場合、ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－8000する。
-- （パワーが０以下のシグニはルールによってバニッシュされる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「バズイールとブロトを加えた場合」의 뒷부분(대상 상대 시그니)은 근사: －12000
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_BIKOU) end,tp,LOCATION_TRASH,0,3,3,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local g=Duel.GetTargets():Filter(function(x) return x:IsRelateToEffect(e) end,nil)
    local a,b=false,false
    for x in g:Iter() do if x:IsCardName(6967) then a=true end if x:IsCardName(6969) then b=true end end
    if g:GetCount()>0 then Duel.SendToDeckShuffle(g) end
    if a and b then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-8000) end
    end
  end)
  c:RegisterEffect(e1)
end
