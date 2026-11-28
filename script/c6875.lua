-- WXK09-001 糾う者
-- 【常】：このルリグにグロウするためのルリグタイプは無視される。
-- 【自】：あなたのメインフェイズ開始時、センタールリグの下から対象のカード１枚をルリグトラッシュに置くか、シグニゾーンかエナゾーンから対象のカード１枚をトラッシュに置くか、ライフクロス１枚をトラッシュに置く。
-- 【出】：無色ではないシグニのカード名１つを宣言する。このゲームの間、あなたのメインデッキと手札と場にある宣言したシグニの基本レベルは０になり、あなたは宣言したシグニを限定条件を無視して場に出せる。
local s,id=GetID()
function s.initial_effect(c)
  -- 【常】「グロウするためのルリグタイプは無視される」와 그로우 코스트 「…×５orキー」는 아직
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp,eg)
    local lc=e:GetHandler()
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 then
      local g=lc:GetUnderGroup()
      if g:GetCount()>0 then Duel.SendToLrigTrash(Duel.SelectCards(tp,g,1,1),REASON_EFFECT) end
    elseif m==1 then
      local x=Duel.SelectTarget(tp,nil,tp,LOCATION_SZONE+LOCATION_ENA,0,1,1,nil):GetFirst()
      if x then Duel.SendToTrash(x,REASON_EFFECT) end
    else
      local l=Duel.GetMatchingGroup(nil,tp,LOCATION_LIFE,0,nil)
      if l:GetCount()>0 then Duel.SendToTrash(Duel.SelectCards(tp,l,1,1),REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  -- [の間] このゲームの間(근사: 「限定条件を無視して場に出せる」는 아직)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    local cid=Duel.AnnounceCard(tp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_LEVEL)
    e1:SetTargetRange(LOCATION_MDECK+LOCATION_HAND+LOCATION_SZONE,0)
    e1:SetTarget(function(e,x) return x:IsSigni() and x:IsCardName(cid) end)
    e1:SetValue(0)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e2)
end
