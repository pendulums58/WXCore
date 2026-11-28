-- WXEX1-32 幻怪姫　ヌエ
-- 【レイヤー】あなたの＜怪異＞のシグニは《レイヤーアイコン》の能力を得る
-- 《レイヤーアイコン》【常】：このシグニによってクラッシュされた対戦相手のカードのライフバーストは発動しない。
-- 【出】：あなたのデッキから＜怪異＞のシグニを２枚まで探してトラッシュに置き、デッキをシャッフルする。ターン終了時まで、このシグニはこの方法でトラッシュに置いたシグニのすべての《レイヤーアイコン》の能力を得る。
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【レイヤー】 「このシグニによってクラッシュされた対戦相手のカードのライフバーストは発動しない」(코어 미지원, 분류용 마커)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:IsSigni() and x:IsClass(0,RACE_KAII) end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local g=aux.Search(tp,aux.ClassFilter(0,RACE_KAII),2)
    local sent=Group.CreateGroup()
    for x in g:Iter() do
      if Duel.SendToTrash(x,REASON_EFFECT)>0 then sent:AddCard(x) end
    end
    aux.ShuffleDeck(tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then
      for x in sent:Iter() do
        if aux.HasLayer(x) and x:HasAbility() then Duel.GainAbilities(h,x,RESET_PHASE+PHASE_END) end
      end
    end
  end)
  c:RegisterEffect(e2)
end
