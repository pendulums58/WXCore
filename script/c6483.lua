-- WXK04-027 羅植姫　ガランサス
-- 【出】：色１つを宣言する。あなたのデッキの一番上を公開し、それが宣言した色を持つカードの場合、それをエナゾーンに置く。
-- 【自】：各ターン終了時、あなたのエナゾーンにあるカードの色が２種類以上ある場合、【エナチャージ１】をする。その後、あなたのエナゾーンにあるカードの色が４種類以上ある場合、対戦相手のシグニ１体を対象とし、それをトラッシュに置く。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))
    local col=({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK})[m+1]
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsColor(col) then Duel.SendToEna(x) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_TURN_END)
  e2:SetRange(LOCATION_SZONE)
  e2:SetOperation(function(e,tp,eg)
    if (function() local m,n=0,0 for x in Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):Iter() do m=m|x:GetColor() end for _,b in ipairs({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}) do if m&b~=0 then n=n+1 end end return n end)()<2 then return end
    Duel.EnaCharge(tp,1)
    if (function() local m,n=0,0 for x in Duel.GetMatchingGroup(nil,tp,LOCATION_ENA,0,nil):Iter() do m=m|x:GetColor() end for _,b in ipairs({COLOR_WHITE,COLOR_RED,COLOR_BLUE,COLOR_GREEN,COLOR_BLACK}) do if m&b~=0 then n=n+1 end end return n end)()<4 then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToTrash(tc,REASON_EFFECT) end
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetOperation(function(e,tp,eg)
    Duel.Draw(tp,1)
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=4 then Duel.EnaCharge(tp,1) end
  end)
  c:RegisterEffect(e9)
end
