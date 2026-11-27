-- WX09-011 赤爆忍　カクヤ
-- 【出現条件】《メインフェイズアイコン》《手剣　カクマル》１体と《手弾　アヤボン》１体をあなたの場からトラッシュに置く
-- 【自】：このシグニの正面にあるシグニ１体がバニッシュされたとき、《赤》を支払ってもよい。そうした場合、このシグニをアップする。
-- 【出】《赤》《赤》：ターン終了時まで、このシグニは【ダブルクラッシュ】を得る。あなたのセンタールリグがレベル４以上の場合、この能力の発動コストは《赤×2》減る。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,function(x) return x:IsSigni() and not x:IsType(TYPE_RESONA) and (x:IsCardName(1974) or x:IsCardName(1977)) end,nil,nil,nil,function(g) return g:Filter(function(x) return x:IsCardName(1974) end,nil):GetCount()>=1 and g:Filter(function(x) return x:IsCardName(1977) end,nil):GetCount()>=1 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_BANISHED)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() local fz=Duel.GetFrontZone(e:GetHandler():GetZone()) return fz and x:GetPreviousZone()==fz end)
  e1:SetOperation(function(e,tp)
    if not (Duel.CanPayEna(tp,"{R}") and Duel.SelectYesNo(tp)) then return end
    Duel.SendToTrash(Duel.SelectEnaCost(tp,"{R}"),REASON_COST)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EVENT_ON_PLAY)
  -- 센터 루리그가 레벨 4 이상이면 《赤》《赤》가 줄어 코스트 없음
  e2:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local cost=(lc and lc:GetLevel()>=4) and "" or "{R}{R}"
    if chk==0 then return cost=="" or Duel.CanPayEna(tp,cost) end
    if cost~="" then Duel.SendToTrash(Duel.SelectEnaCost(tp,cost),REASON_COST) end
  end)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    if h:IsLocation(LOCATION_SZONE) then aux.GrantKeyword(e,h,EFFECT_DOUBLE_CRUSH) end  -- [まで]
  end)
  c:RegisterEffect(e2)
end
