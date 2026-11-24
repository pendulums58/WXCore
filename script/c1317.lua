-- WD21-001 カーニバル　―ＱＡ―
-- 【自】：あなたのアタックフェイズ開始時、あなたのデッキをシャッフルし一番上を公開する。その後、あなたのシグニ１体を対象とし、ターン終了時まで、それは、この方法で公開したカードがレベル１のシグニの場合、【ダブルクラッシュ】を得る。レベル２の場合、【アサシン】を得る。レベル３の場合、【ランサー】を得る。レベル４の場合、「【常】：バニッシュされない。」を得る。
-- 【出】《コインアイコン》《コインアイコン》：あなたのデッキの一番上を公開する。それがシグニの場合、あなたはそのシグニのレベル１につきカードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_ATTACK)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep) return ep==tp end)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCoinCost(2)
  e2:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,1)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.RevealCards(g)
    if tc:IsSigni() then Duel.Draw(tp,aux.RefLevel(tp,tc)) end
  end)
  c:RegisterEffect(e2)
end
s.grants={EFFECT_DOUBLE_CRUSH,EFFECT_ASSASSIN,EFFECT_LANCER,EFFECT_CANNOT_BANISH}
-- 대상은 공개한 카드를 보고 고른다(FAQ 1). 시그니가 없어도 공개한다(FAQ 4)
function s.op(e,tp)
  aux.ShuffleDeck(tp)
  local g=Duel.GetDecktopGroup(tp,1)
  local top=g:GetFirst()
  if not top then return end
  Duel.RevealCards(g)
  local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
  if not (tc and top:IsSigni()) then return end
  local code=s.grants[aux.RefLevel(tp,top)]
  if code then aux.GrantKeyword(e,tc,code) end  -- [まで] ターン終了時まで
end
