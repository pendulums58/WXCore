-- WX13-048 幻水　テッポウオ
-- 【出】手札から＜水獣＞のシグニを１枚捨てる：あなたはカード名１つを宣言する。対戦相手は自分のデッキの一番上のカードを公開する。それが宣言したカードの場合、それをトラッシュに置き、あなたはカードを２枚引く。宣言したカードではない場合、あなたはカードを１枚引く。
-- ライフバースト：カードを１枚引き、対戦相手のデッキの一番上と対戦相手のライフクロスの一番上を見る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetCost(aux.DiscardCost(1,function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end))
  e1:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    local x=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(x)
    if x:IsCardName(cid) then
      Duel.SendToTrash(x,REASON_EFFECT)
      Duel.Draw(tp,2)
    else
      Duel.Draw(tp,1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    Duel.Draw(tp,1)
    local d=Duel.GetDecktopGroup(1-tp,1)
    if d:GetCount()>0 then Duel.ConfirmCards(tp,d) end
    local l=Duel.GetMatchingGroup(nil,1-tp,LOCATION_LIFE,0,nil):GetFirst()
    if l then Duel.ConfirmCards(tp,l) end
  end)
  c:RegisterEffect(e2)
end
