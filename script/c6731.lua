-- WXK07-033 羅星姫　オルネ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、対戦相手のセンタールリグのレベル以下の数字１つを宣言する。ターン終了時まで、それの基本レベルを宣言した数字にする。
-- 【出】《黒》：あなたのトラッシュからレベル３以下の黒のシグニ１枚を対象とし、それを手札に加える。
-- ライフバースト：カードを１枚引く。あなたのライフクロスが４枚以下の場合、追加で【エナチャージ１】をする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      local n=Duel.AnnounceNumber(tp,0,Duel.GetMatchingGroup(nil,1-tp,LOCATION_LRIG,0,nil):GetFirst():GetLevel())
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CHANGE_LEVEL)
      e1:SetValue(n)
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetEnaCost("{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToHand(tc)
    end
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
