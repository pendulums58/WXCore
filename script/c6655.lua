-- WXK06-040 コードメイズ　トロニス
-- 【自】《ターン１回》：このシグニがアタックしたとき、数字１つを宣言する。対戦相手のデッキの一番上のカードをトラッシュに置く。それが宣言した数字と同じレベルのシグニの場合、このシグニをアップする。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のレベル２以下のシグニ１体を対象とし、それをダウンする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp,eg)
    local lv=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(1-tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    local h=e:GetHandler()
    if x:IsSigni() and x:GetLevel()==lv and h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetDeclare(function(e,tp) e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))) end)
  e9:SetOperation(function(e,tp,eg)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=2 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.Down(tc) end
  end)
  c:RegisterEffect(e9)
end
