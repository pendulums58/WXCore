-- WDK06-C07 バッド・エンド
-- アンコール －《コインアイコン》（アンコールコストを追加で支払って使用してもよい。そうした場合、これは追加で「このカードをルリグデッキに戻す。」を得る）
-- あなたのデッキの上からカードを５枚トラッシュに置く。その後、この方法で黒のカードが５枚トラッシュに置かれた場合、あなたのトラッシュから黒のシグニ１枚を対象とし、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(1)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()==0 then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    -- 덱이 4장 이하면 5장이 되지 않아 뒷부분은 하지 않는다(FAQ 2)
    if g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and x:IsColor(COLOR_BLACK) end,nil):GetCount()<5 then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst()
    if tc then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e1)
end
