-- WDK07-E20 ＳＷＥＥＴ　ＣＨＡＲＧＥ
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜調理＞のシグニ１体を場からトラッシュに置く。そうした場合、あなたのデッキから＜調理＞のシグニ１枚を探して対象のあなたの＜調理＞のシグニ１体の【アクセ】にし、デッキをシャッフルする。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.chouri=aux.ClassFilter(0,RACE_CHOURI)  -- ＜調理＞のシグニ
function s.initial_effect(c)
  local mine,host  -- 놓을 시그니, 【アクセ】를 붙일 시그니
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- ①은 둘을 처리 직전에 함께 고른다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    mine,host=nil,nil
    if e:GetLabel()==1 then return end
    mine=Duel.SelectTarget(tp,s.chouri,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    host=Duel.SelectTarget(tp,s.chouri,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    if not (mine and mine:IsRelateToEffect(e) and Duel.SendToTrash(mine,REASON_EFFECT)>0) then return end
    -- 붙일 시그니가 없으면 찾은 카드는 덱으로 돌아간다(FAQ 3)
    local ac=aux.Search(tp,s.chouri,1):GetFirst()
    if ac and host and host:IsRelateToEffect(e) then Duel.Acce(ac,host) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
