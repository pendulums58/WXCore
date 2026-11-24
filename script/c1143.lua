-- WD06-009 幻水　シィラ
-- 【常】：あなたのライフクロスが対戦相手より少ないかぎり、あなたのシグニのパワーを＋1000する。
-- 【出】《青》：あなたのライフクロス１枚をクラッシュする。この方法でチェックゾーンに置かれたカードがエナゾーンに置かれる場合、代わりにそれをトラッシュへ置きあなたのデッキの一番上のカードをライフクロスに加える。
-- ライフバースト：カードを２枚引き、手札を１枚捨てる。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SIGNI,0)
  e1:SetValue(1000)
  e1:SetCondition(function(e)
    local tp=e:GetHandlerPlayer()
    local function n(p) return Duel.GetMatchingGroup(nil,p,LOCATION_LIFE,0,nil):GetCount() end
    return n(tp)<n(1-tp)
  end)
  c:RegisterEffect(e1)
  -- 크러시 → (버스트) → 에나 대신 트래시 + 덱 위를 라이프에(WD06-001 FAQ 1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{U}")
  e2:SetOperation(function(e,tp) Duel.Crush(tp,1,true) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    Duel.Draw(tp,2)
    aux.Discard(tp,1)
  end)
  c:RegisterEffect(e3)
end
