-- WX21-Re20 ＤＹＮＡＭＩＴＥ
-- あなたのデッキの上からカードを２枚見る。その中から１枚をチェックゾーンに置き、残りを手札に加える。この方法でチェックゾーン置いたカードのライフバーストを発動する。そのカードがチェックゾーンを離れる場合、代わりにトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,1,1):GetFirst()
    local rest=g:Filter(function(c) return c~=x end,nil)
    if rest:GetCount()>0 then Duel.SendToHand(rest) end
    -- 「チェックゾーンでライフバーストを発動」: 트래시에 두고 라이프 버스트를 발동시키는 것으로 근사
    if x then Duel.SendToTrash(x,REASON_EFFECT) if x:IsLifeBurst() then Duel.FireLifeBurst(x) end end
  end)
  c:RegisterEffect(e1)
end
