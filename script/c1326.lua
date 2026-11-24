-- WD21-012 羅星　≡チドウ≡
-- 【常】：あなたの能力か効果１つによって、あなたのデッキか手札かトラッシュにある＜宇宙＞のシグニのレベルを参照する場合、１～４いずれかのレベル１つとして扱ってもよい。
-- 【自】：このシグニがアタックしたとき、あなたのデッキの上からカードを３枚トラッシュに置く。この方法でトラッシュに置いたシグニのレベルの合計が１０の場合、対象の対戦相手のパワー7000以下のシグニ１体をバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】 효과 하나에 레벨 하나. 여러 체 있어도 같다(FAQ 3)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_ANY_LEVEL)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_MDECK+LOCATION_HAND+LOCATION_TRASH,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_UCHU) end)
  c:RegisterEffect(e1)
  -- 조건과 관계없이 어택했을 때 대상을 고른다(FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ATTACK)
  e2:SetTarget(aux.BanishPowerTarget(7000))
  e2:SetOperation(s.op)
  c:RegisterEffect(e2)
end
function s.op(e,tp)
  local g=Duel.GetDecktopGroup(tp,3)
  if g:GetCount()==0 then return end
  Duel.SendToTrash(g,REASON_EFFECT)
  local lo,hi=0,0  -- 1~4로 칠 수 있는 카드가 있으면 합계는 lo~hi 어느 것이든 된다(FAQ 2)
  for x in g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsSigni() end,nil):Iter() do
    local any,lv=x:HasKeyword(EFFECT_ANY_LEVEL),x:GetLevel()
    lo=lo+(any and math.min(1,lv) or lv)
    hi=hi+(any and math.max(4,lv) or lv)
  end
  local tc=Duel.GetFirstTarget()
  if lo<=10 and 10<=hi and tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
end
