-- WXK10-051 幻武竜　リョーマ
-- 【自】：このシグニがアタックしたとき、対戦相手のシグニ１体を対象とし、あなたのトラッシュからそれぞれレベルの異なる黒のシグニ４枚をデッキに加えてもよい。そうした場合、デッキをシャッフルし、ターン終了時まで、それのパワーをこのシグニのパワーの半分だけ－（マイナス）する。
-- 【起】《ターン２回》《黒》：あなたの黒のシグニ１体を対象とし、ターン終了時まで、それのパワーを＋5000する。あなたのデッキの上からカードを３枚トラッシュに置く。
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
      local g=Duel.GetMatchingGroup(function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_TRASH,0,nil)
      if g:GetCount()<4 or not Duel.SelectYesNo(tp) then return end
      Duel.SetSelectCheck(aux.DistinctLevels)
      local sg=Duel.SelectCards(tp,g,0,4)
      if sg:GetCount()<4 then return end
      Duel.SendToDeckShuffle(sg)
      aux.AddPower(e,tc,-math.floor(e:GetHandler():GetPower()/2))
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_SZONE)
  e2:SetCountLimit(2)
  e2:SetEnaCost("{B}")
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsColor(COLOR_BLACK) end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.AddPower(e,tc,5000)
      local g=Duel.GetDecktopGroup(tp,3)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e2)
end
