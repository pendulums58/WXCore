-- WD23-014-A トリップ・トラップ
-- あなたの【トラップ】１つを対象とし、それを表向きにし《トラップアイコン》を発動させる。（その後、発動した【トラップ】はトラッシュに置かれる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRAP,0,1,1,nil)
  end)
  -- 같은 존에 시그니가 있어도 된다(FAQ 2)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.OpenTrap(tc) end
  end)
  c:RegisterEffect(e1)
end
