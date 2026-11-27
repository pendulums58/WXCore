-- WX20-043 幻水　ヒナニギス
-- 【自】：あなたのアタックフェイズ開始時、あなたのトラッシュにカード名に《デメニギス》を含むカードがある場合、あなたのライフクロス１枚をクラッシュしてもよい。この方法でチェックゾーンに置かれたカードがエナゾーンに置かれる場合、代わりにそれをトラッシュへ置きあなたのデッキの一番上のカードをライフクロスに加える。
-- 【出】《青》《無》：あなたのトラッシュからカード１枚を対象とし、あなたの場にカード名に《デメニギス》を含むシグニがある場合、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【自】 「ライフクロス１枚をクラッシュ…代わりにライフに加える」는 아직(근사 없음)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetEnaCost("{U}{C}")
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,nil,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then if Duel.GetMatchingGroup(function(x) return aux.NameHas(x,"デメニギス") end,tp,LOCATION_SZONE,0,nil):GetCount()>0 then Duel.SendToDeckPosition(tc,1) end end
  end)
  c:RegisterEffect(e1)
end
