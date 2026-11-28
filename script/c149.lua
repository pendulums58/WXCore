-- PR-257 ディストラクト・スルー（劇場版selector来場特典）
-- ターン終了時まで、あなたのセンタールリグは
-- 「【起】エクシード１：カードを１枚引く。」
-- 「【起】エクシード１：対戦相手のシグニ１体を対象とし、それを凍結する。」
-- 「【起】エクシード２：カード名１つを宣言する。その後、対戦相手の手札を見て、宣言したカードをすべて捨てさせる。」
-- を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,0))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(1)
      g:SetOperation(function(e2,tp2)
        Duel.Draw(tp2,1)
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,1))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(1)
      g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.SelectTarget(tp2,Card.IsSigni,tp2,0,LOCATION_SZONE,1,1,nil)
      end)
      g:SetOperation(function(e2,tp2)
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e2) then Duel.Freeze(tc) end
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
    do
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_IGNITION)
      g:SetDescription(aux.Stringid(id,2))
      g:SetRange(LOCATION_LRIG)
      g:SetExceedCost(2)
      g:SetOperation(function(e2,tp2)
        local cid=Duel.AnnounceCard(tp2)
        local h=Duel.GetMatchingGroup(nil,tp2,0,LOCATION_HAND,nil)
        Duel.ConfirmCards(tp2,h)
        local g=h:Filter(function(x) return x:IsCardName(cid) end,nil)
        if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT+REASON_DISCARD) end
      end)
      g:SetReset(RESET_PHASE+PHASE_END)
      lc:GrantEffect(g)
    end
  end)
  c:RegisterEffect(e1)
end
