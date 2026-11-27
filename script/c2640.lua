-- WX13-069 爆砲　フウバ
-- 《クロスアイコン》《爆砲　ファイバル》の右
-- 【クロス常】：このシグニの基本パワーは8000になる。
-- 【自】：このシグニがバニッシュされたとき、《赤》を支払ってもよい。そうした場合、あなたのデッキから《クロスアイコン》を持つレベル３以下のシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddCross(c,2639,CROSS_RIGHT)
  -- [の間] 【クロス常】
  aux.BasePower(c,8000,function(e) return e:GetHandler():IsCross() end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetCode(EVENT_BANISHED)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    aux.SearchToHand(tp,function(x) return x:IsSigni() and x:HasCrossIcon() and x:GetLevel()<=3 end,1)
  end)
  c:RegisterEffect(e1)
end
