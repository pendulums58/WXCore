-- WXK06-029 フリーダム団　ワイルドライガー
-- 【常】：あなたがデッキからカードを探している間、このカードをデッキから公開し《青》《無》 を支払ってもよい。そうした場合、これを手札に加える。
-- 【自】：場にあるシグニ１体が他のシグニゾーンに移動したとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－2000する。
-- 【出】：あなたか対戦相手の場にあるすべてのシグニを好きなように配置し直す。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】「デッキからカードを探している間、このカードを公開し…手札に加える」는 아직
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_SIGNI_MOVED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-2000)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- 「好きなように配置し直す」(근사: 두 체의 자리를 한 번 바꾼다)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local p=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))==0 and tp or 1-tp
    local g=Duel.GetMatchingGroup(Card.IsSigni,p,LOCATION_SZONE,0,nil)
    if g:GetCount()<2 then return end
    local t=Duel.SelectCards(tp,g,2,2)
    local a=t:GetFirst()
    local b=nil
    for x in t:Iter() do if x~=a then b=x end end
    Duel.SwapSigni(a,b)
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
