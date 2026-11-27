-- WX19-003 エルドラ×マークⅤ　ＭＡＳＴＥＲ
-- 【常】：あなたの手札の枚数の上限は２増える。（６枚から８枚になる）
-- 【自】《ターン１回》：対戦相手のターンの間、あなたの＜水獣＞のシグニ１体が場を離れたとき、あなたの手札からそのシグニより低いレベルを持つ＜水獣＞のシグニ１枚を場に出してもよい。
-- 【出】：あなたの場にある＜水獣＞のシグニ１体につきカードを２枚引く。
-- 【起】《ターン２回》《アタックフェイズアイコン》エクシード１：あなたのデッキから＜水獣＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_HAND_LIMIT)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(1,0)
  e1:SetValue(2)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return Duel.GetTurnPlayer()~=tp and x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(x) end)
  e2:SetOperation(function(e,tp,eg)
    local lv=eg:GetFirst():GetLevel()
    local x=Duel.SelectCards(tp,Duel.GetMatchingGroup(function(c) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(c) and c:GetLevel()<lv end,tp,LOCATION_HAND,0,nil),0,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetCode(EVENT_ON_PLAY)
  e3:SetOperation(function(e,tp)
    local n=Duel.GetMatchingGroup(function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,tp,LOCATION_SZONE,0,nil):GetCount()
    if n>0 then Duel.Draw(tp,2*n) end
  end)
  c:RegisterEffect(e3)
  local e4=Effect.CreateEffect(c)
  e4:SetType(EFFECT_TYPE_IGNITION)
  e4:SetDescription(aux.Ability(id,3))
  e4:SetRange(LOCATION_LRIG)
  e4:SetCountLimit(2)
  e4:SetExceedCost(1)
  e4:SetTiming(TIMING_ATTACK)
  e4:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e4)
end
