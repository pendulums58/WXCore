-- WX20-023 幻怪　フゥライ
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【常】：対戦相手の効果によって、このシグニのパワーは増減しない。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《白》：あなたのトラッシュから＜怪異＞のシグニ１枚を対象とし、ターン終了時まで、このシグニはそれの《レイヤーアイコン》能力１つを得る。
-- ライフバースト：あなたのデッキから【レイヤー】を持つシグニ１枚を探して公開し、手札に加えるか場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_NO_OPP_POWER_CARD)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return (function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end)(x) end)
  c:RegisterEffect(e1)
  -- 【起】 「それの《レイヤーアイコン》能力１つを得る」는 아직(근사 없음)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_KAII)) end,1):GetFirst()  -- 「【レイヤー】を持つ」는 ＜怪異＞로 근사
    if x then
      Duel.RevealCards(Group.CreateGroup(x))
      if Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) else Duel.SendToHand(x) end
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e2)
end
