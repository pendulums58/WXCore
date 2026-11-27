-- WX05-020 羅輝石　ダイヤブライド
-- 【自】《ターン１回》：このシグニが１ターンにライフクロスを合計２枚以上クラッシュしたとき、このシグニをアップする。
-- 【自】《ターン１回》：あなたの＜鉱石＞か＜宝石＞のシグニ１体が対戦相手のアーツの効果を受けたとき、対戦相手にダメージを与える。（対戦相手のライフクロスがない場合、あなたはゲームに勝利する）
-- ライフバースト：対戦相手のパワー10000以下のシグニ１体を対象とし、それをバニッシュする。あなたのライフクロスが２枚以下の場合、追加で対戦相手のライフクロス１枚をクラッシュする。
local s,id=GetID()
function s.initial_effect(c)
  -- 이 시그니가 이 턴에 크러시한 장수. 2장이 되면 업(턴 1회)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg,ep)
    if not (ep~=tp and Duel.GetCrusher()==e:GetHandler()) then return false end
    local t=Duel.GetTurnCount()
    if s.turn~=t then s.turn,s.n,s.done=t,0,false end
    s.n=s.n+1
    return s.n>=2 and not s.done
  end)
  e1:SetOperation(function(e,tp)
    s.done=true
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  -- 상대 아츠의 수치·상태 변경이나 이동을 받았을 때(FAQ 2)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ARTS_HIT)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(1)
  e2:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:GetControler()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KOUSEKI) or x:IsClass(0,RACE_HOUSEKI)) end)(x) end)
  e2:SetOperation(function(e,tp)
    Duel.Damage(1-tp)
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetTarget(aux.BanishPowerTarget(10000))
  e3:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.Banish(tc) end
    if Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil):GetCount()<=2 then Duel.Crush(1-tp,1) end
  end)
  c:RegisterEffect(e3)
end
