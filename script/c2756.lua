-- WX15-016 スリップ・ノット
-- ターン終了時まで、あなたのセンタールリグは「【自】：対戦相手のシグニ１体がアタックしたとき、あなたのデッキの一番上のカードをトラッシュに置いてもよい。この方法でトラッシュに置いたカードが《バーストアイコン》を持っていた場合、そのアタックを無効にする。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(function(e,tp)
    -- [の間] 「ターン終了時まで」 센터 루리그가 얻는다
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local g=Effect.CreateEffect(lc)
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Stringid(id,0))
    g:SetCode(EVENT_ATTACK)
    g:SetRange(LOCATION_LRIG)
    g:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:GetControler()~=tp2 and x:IsSigni() end)
    g:SetOperation(function(e2,tp2)
      local x=Duel.GetDecktopGroup(tp2,1):GetFirst()
      if not (x and Duel.SelectYesNo(tp2)) then return end
      Duel.SendToTrash(x,REASON_EFFECT)
      if x:IsLifeBurst() then Duel.NegateAttack() end
    end)
    g:SetReset(RESET_PHASE+PHASE_END)
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
