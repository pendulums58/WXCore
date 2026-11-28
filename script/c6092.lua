-- WXEX1-58 羅星　ピクター
-- 【自】：このシグニが＜宇宙＞のレゾナの出現条件のために場からトラッシュに置かれたとき、次のあなたのターンまで、そのレゾナは対戦相手のルリグの効果を受けない。
-- 【出】：数字１つを宣言する。あなたのデッキの一番上を公開し、それが宣言した数字と同じレベルを持つシグニの場合、それを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_TO_TRASH)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r)
    if r&REASON_RESONA==0 or not e:GetHandler():IsPreviousLocation(LOCATION_SZONE) then return false end
    local rc=re and re:GetHandler()
    return rc and rc:IsClass(0,RACE_UCHU)
  end)
  e1:SetOperation(function(e,tp,eg,ep,ev,re)
    local rc=re and re:GetHandler()
    if rc and rc:IsLocation(LOCATION_SZONE) then
      -- [まで] 次のあなたのターンまで対戦相手のルリグの効果を受けない
      local e0=Effect.CreateEffect(e:GetHandler())
      e0:SetType(EFFECT_TYPE_SINGLE)
      e0:SetCode(EFFECT_IMMUNE)
      e0:SetValue(function(ef,sc,sp) return sp~=tp and sc and sc:IsType(TYPE_LRIG) end)
      e0:SetReset(RESET_PHASE+PHASE_END+RESET_MY_TURN)
      rc:RegisterEffect(e0)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    local lv=Duel.AnnounceNumber(tp,1,5)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:IsLevelBetween(lv,lv) then Duel.SendToHand(x) end
  end)
  c:RegisterEffect(e2)
end
