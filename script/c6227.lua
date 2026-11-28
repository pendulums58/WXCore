-- WXK01-044 超罠　Ｊ・リッパー
-- 【自】：このシグニがアタックしたとき、数字１つを宣言する。その後、あなたのデッキの一番上のカードをトラッシュに置く。それが宣言した数字と同じレベルのシグニの場合、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－10000する。
-- 【出】：ターン終了時まで、レベルが偶数の対戦相手のシグニ１体のパワーを－5000する。
-- ライフバースト：対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－12000する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetOperation(function(e,tp,eg)
    -- 대상은 트래시에 둔 뒤에(FAQ 2)
    local lv=Duel.AnnounceNumber(tp,0,5)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.SendToTrash(g,REASON_EFFECT)
    if not (x:IsSigni() and x:GetLevel()==lv) then return end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then aux.AddPower(e,tc,-10000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp,eg)
    -- 대상이 아니다
    local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:GetLevel()%2==0 end,tp,0,LOCATION_SZONE,nil)
    if g:GetCount()>0 then aux.AddPower(e,Duel.SelectCards(tp,g,1,1):GetFirst(),-5000) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e2)
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_LIFEBURST)
  e9:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e9:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,-12000)
    end
  end)
  c:RegisterEffect(e9)
end
