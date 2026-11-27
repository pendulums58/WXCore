-- WX04-038 バイオレンス・スプラッシュ
-- このターン、パワーが０以下のシグニがバニッシュされる場合、そのシグニはエナゾーンに置かれる代わりにトラッシュに置かれる。このターン、あなたのシグニの効果で対戦相手のシグニのパワーが－（マイナス）される場合、代わりに２倍－（マイナス）される。
-- ライフバースト：あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加えるか場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「このターン」 둘 다 겹친다(FAQ 1)
    for _,code in ipairs{EFFECT_ZERO_TO_TRASH,EFFECT_DOUBLE_MINUS} do
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_FIELD)
      e1:SetCode(code)
      e1:SetTargetRange(1,code==EFFECT_ZERO_TO_TRASH and 1 or 0)
      e1:SetReset(RESET_PHASE+PHASE_END)
      Duel.RegisterEffect(e1,tp)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if not (Duel.SelectYesNo(tp) and Duel.PutOnField(tc,tp)) then Duel.SendToHand(tc) end end
  end)
  c:RegisterEffect(e2)
end
