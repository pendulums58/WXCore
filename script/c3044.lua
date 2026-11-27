-- WX19-014 ゲット・アップ
-- アンコール －《コインアイコン》
-- ターン終了時まで、あなたのセンタールリグは「【自】《ターン１回》：このルリグがアタックしたとき、このルリグをアップする。」を得る。
-- （この能力を２つ以上得ても最初のアタックですべて発動し２回目のアタックでは発動しない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetEncore(1)
  e1:SetOperation(function(e,tp)
    -- [の間] 「ターン終了時まで」 센터 루리그가 얻는다
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local g=Effect.CreateEffect(lc)
    g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Stringid(id,0))
    g:SetCode(EVENT_ATTACK)
    g:SetCountLimit(1)
    g:SetOperation(function(e2) local h=e2:GetHandler() if h:IsLocation(LOCATION_LRIG) then Duel.Up(h) end end)
    g:SetReset(RESET_PHASE+PHASE_END)
    lc:GrantEffect(g)
  end)
  c:RegisterEffect(e1)
end
