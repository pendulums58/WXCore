-- WX15-001 真実の記憶　リル
-- 【常】：《ライズアイコン》を持つあなたの＜武勇＞のシグニのパワーを＋3000する。
-- 【自】：あなたのメインフェイズ開始時、あなたのデッキの一番上を見る。それが赤のシグニの場合、それを場に出してもよい。
-- 【起】オーネスト《コインアイコン》：対戦相手は自分の手札を公開し、その後、自分のルリグデッキからカードを３枚選び公開する。（２枚以下しかない場合はすべて公開する）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_UPDATE_POWER)
  e1:SetRange(LOCATION_LRIG)
  e1:SetTargetRange(LOCATION_SZONE,0)
  e1:SetTarget(function(e,x) return x:HasRiseIcon() and x:IsClass(0,RACE_BUYU) end)
  e1:SetValue(3000)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e2:SetRange(LOCATION_LRIG)
  e2:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e2:SetOperation(function(e,tp)
    local x=Duel.GetDecktopGroup(tp,1):GetFirst()
    if not x then return end
    Duel.ConfirmCards(tp,Group.CreateGroup(x))
    if x:IsSigni() and x:IsColor(COLOR_RED) and Duel.SelectYesNo(tp) then Duel.PutOnField(x,tp) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp)
    local h=Duel.GetMatchingGroup(nil,tp,0,LOCATION_HAND,nil)
    if h:GetCount()>0 then Duel.ConfirmCards(tp,h) end
    local l=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LDECK,nil)
    if l:GetCount()>0 then Duel.ConfirmCards(tp,Duel.SelectCards(1-tp,l,math.min(3,l:GetCount()),3)) end
  end)
  c:RegisterEffect(e3)
end
