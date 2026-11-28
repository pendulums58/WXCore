-- WXK10-004 プロテクション・マッピング
-- あなたのセンタールリグのレベル１につきカードを１枚引くか、あなたのセンタールリグのレベル１につき【エナチャージ１】をする。あなたのデッキの一番上のカードをライフクロスに加える。
-- このターンと次のターンの間、場以外のあなたの領域にあるカードは、対戦相手の効果によって他の領域に移動しない。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  -- 「場以外のあなたの領域にあるカードは…移動しない」는 아직
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp,eg)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local n=lc and lc:GetLevel() or 0
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Draw(tp,n) else Duel.EnaCharge(tp,n) end
    local g=Duel.GetDecktopGroup(tp,1)
    if g:GetCount()>0 then Duel.SendToLife(g) end
  end)
  c:RegisterEffect(e1)
end
