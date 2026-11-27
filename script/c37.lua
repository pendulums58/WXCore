-- WX12-Re22 ネクスト・レディ
-- あなたのセンタールリグの下からカードを好きな枚数対象とし、それらをルリグトラッシュに置く。その後、以下の４つから、この方法でルリグトラッシュに置いたカードの枚数と同じ数まで選ぶ。
-- ①対戦相手のシグニ１体を対象とし、ターン終了時まで、それは能力を失う。
-- ②カードを１枚引く。
-- ③あなたのデッキの一番上のカードをエナゾーンに置く。
-- ④各プレイヤーは自分のデッキの上からカードを４枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 처리는 위에서부터(FAQ 4)
  e1:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    if not lc then return end
    local u=lc:GetUnderGroup()
    local g=Duel.SelectCards(tp,u,0,u:GetCount())
    local n=g:GetCount()>0 and Duel.SendToLrigTrash(g) or 0
    if n==0 then return end
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,0,math.min(n,4),aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do m=m|(1<<i) end
    if m&1~=0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_LOSE_ABILITY)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
      end
    end
    if m&2~=0 then Duel.Draw(tp,1) end
    if m&4~=0 then Duel.EnaCharge(tp,1) end
    if m&8~=0 then for _,p in ipairs({tp,1-tp}) do local d=Duel.GetDecktopGroup(p,4) if d:GetCount()>0 then Duel.SendToTrash(d,REASON_EFFECT) end end end
  end)
  c:RegisterEffect(e1)
end
