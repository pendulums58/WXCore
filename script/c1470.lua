-- WX16-024 幻怪姫　カラテン
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【常】：このシグニは対戦相手のパワー15000以上のシグニの効果を受けない。
-- 《レイヤーアイコン》【自】：このシグニが対戦相手の効果によって場を離れたとき、カードを２枚引く。
-- ライフバースト：あなたのデッキから＜怪異＞のシグニを１枚探して公開し、手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】 이 시그니가 있으면 ＜怪異＞ 시그니가 아래 두 능력을 얻는다
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  e1:SetCode(EFFECT_IMMUNE)
  e1:SetValue(function(e,sc,sp) return sp~=e:GetHandlerPlayer() and sc:IsSigni() and sc:GetPower()>=15000 end)
  c:RegisterEffect(e1)
  local g=Effect.CreateEffect(c)
  g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  g:SetDescription(aux.Ability(id,0))
  g:SetCode(EVENT_LEAVE_FIELD)
  g:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_EFFECT~=0 and rp~=tp end)
  g:SetOperation(function(e,tp) Duel.Draw(tp,2) end)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetDescription(aux.Ability(id,0))
  e2:SetRange(LOCATION_SZONE)
  e2:SetTargetRange(LOCATION_SZONE,0)
  e2:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  e2:SetCode(EFFECT_GRANT)
  e2:SetLabelObject(g)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,1):GetFirst()
    if x then
      Duel.RevealCards(Group.CreateGroup(x))
      -- 예 = 장에 낸다, 아니오 = 패
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e3)
end
