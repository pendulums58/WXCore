-- WDK07-Y20 プラント・アレンジ
-- 以下の２つから１つを選ぶ。
-- ①対象のあなたの＜植物＞のシグニ１体を場からトラッシュに置く。そうした場合、対象のあなたの【シード】１枚を手札に加え、あなたのデッキの一番上を見て、それを【シード】としてあなたのシグニゾーンに出す。
-- ②【エナチャージ１】（あなたのデッキの一番上のカードをエナゾーンに置く）
local s,id=GetID()
s.shoku=aux.ClassFilter(0,RACE_SHOKUBUTSU)  -- ＜植物＞のシグニ
function s.initial_effect(c)
  local mine,seed  -- 놓을 시그니, 패에 넣을 【シード】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  -- ①은 둘을 처리 직전에 함께 고른다(FAQ 1)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    mine,seed=nil,nil
    if e:GetLabel()==1 then return end
    mine=Duel.SelectTarget(tp,s.shoku,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    seed=Duel.SelectTarget(tp,nil,tp,LOCATION_SEED,0,1,1,nil):GetFirst()
  end)
  e1:SetOperation(function(e,tp)
    if e:GetLabel()==1 then
      Duel.EnaCharge(tp,1)
      return
    end
    -- 내 시그니를 놓지 못하면 뒷부분은 하지 않는다(FAQ 2). 【シード】가 없어도 덱에서는 낸다(FAQ 3·4)
    if not (mine and mine:IsRelateToEffect(e) and Duel.SendToTrash(mine,REASON_EFFECT)>0) then return end
    if seed and seed:IsRelateToEffect(e) then Duel.SendToHand(seed) end
    local top=Duel.GetDecktopGroup(tp,1)
    if top:GetCount()==0 then return end
    Duel.ConfirmCards(tp,top)
    Duel.SetSeed(top:GetFirst(),tp)
  end)
  c:RegisterEffect(e1)
end
