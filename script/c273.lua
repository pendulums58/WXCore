-- PR-431 サーバント　Ａ（ウィクロスマガジンvol.8）
-- 【常】：【マルチエナ】
-- 【出】：＜精像＞か＜精武＞か＜精羅＞か＜精械＞か＜精生＞から１つを宣言する。あなたのデッキの上からカードを４枚公開する。その中から宣言したクラスを持つシグニ１枚を手札に加え、残りをトラッシュに置く。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②【エナチャージ１】
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_MULTI_ENA)
  e1:SetRange(LOCATION_SZONE)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  -- 있으면 반드시 고른다(FAQ 1)
  e2:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4),aux.Stringid(id,5),aux.Stringid(id,6))
    local sys={SYS_SEIZOU,SYS_SEIBU,SYS_SEIRA,SYS_SEIKAI,SYS_SEISEI}
    local g=Duel.GetDecktopGroup(tp,4)
    if g:GetCount()==0 then return end
    Duel.RevealCards(g)
    local c=g:Filter(function(x) return x:IsSigni() and x:IsClass(sys[m+1],0) end,nil)
    if c:GetCount()>0 then Duel.SendToHand(Duel.SelectCards(tp,c,1,1)) end
    local rest=g:Filter(function(x) return x:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToTrash(rest,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    if Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 then Duel.Draw(tp,1) else Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e3)
end
