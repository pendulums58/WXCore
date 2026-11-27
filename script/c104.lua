-- WX16-Re02 轟炎　フレイスロ大尉
-- 【出】：０から５までの数字１つを宣言する。あなたのデッキの上からカードを宣言した数字に等しい枚数トラッシュに置く。その後、この方法でトラッシュに置かれたカードがすべて＜ウェポン＞のシグニである場合、宣言した数字に等しいレベルを持つシグニ１体を対象とし、それをバニッシュする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local n=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,n)
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    if g:Filter(function(x) return not (x:IsSigni() and x:IsClass(0,RACE_WEAPON)) end,nil):GetCount()>0 then return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()==n end,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Banish(tc) end
  end)
  c:RegisterEffect(e1)
end
