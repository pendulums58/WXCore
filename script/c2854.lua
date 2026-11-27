-- WX16-036 アビリティ・マインド
-- 以下の３つから１つを選ぶ。
-- ①あなたのセンタールリグがレベル１かレベル４の場合、あなたのデッキの一番上のカードをエナゾーンに置く。
-- ②あなたのセンタールリグがレベル２かレベル４の場合、カードを１枚引く。
-- ③あなたのトラッシュから無色のシグニ１枚を対象とし、あなたのセンタールリグがレベル３かレベル４の場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))[1])
  end)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local lv=lc and lc:GetLevel() or 0
    local m=e:GetLabel()
    if m==0 and (lv==1 or lv==4) then Duel.EnaCharge(tp,1)
    elseif m==1 and (lv==2 or lv==4) then Duel.Draw(tp,1)
    elseif m==2 then
      local x=Duel.SelectTarget(tp,function(c) return c:IsSigni() and c:GetColor()==0 end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
      if x and (lv==3 or lv==4) then Duel.SendToHand(x) end
    end
  end)
  c:RegisterEffect(e1)
end
