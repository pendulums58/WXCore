-- WD21-007 自由自罪
-- ベット―《コインアイコン》《コインアイコン》
-- 以下の５つから１つを選ぶ。ターン終了時まで、対象のシグニ１体は選んだ能力を得る。あなたがベットしていた場合、この効果を１回繰り返す。
-- （他の選択肢と他のシグニを選んでもよい）
-- ①【アサシン】　　　　　　②【ランサー】
-- ③【ダブルクラッシュ】　　④「【常】：バニッシュされない。」
-- ⑤「【常】：アタックできない。」
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetBet(2)
  e1:SetDeclare(function(e,tp) e:SetLabel(s.mode(tp)) end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    s.target(tp)
  end)
  e1:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then aux.GrantKeyword(e,tc,s.codes[e:GetLabel()+1]) end  -- [まで] ターン終了時まで
    if not Duel.IsBet() then return end
    -- 「１回繰り返す」: 다른 선택지, 다른 시그니(상대 것도)를 골라도 된다(FAQ 1·2)
    local code=s.codes[s.mode(tp)+1]
    tc=s.target(tp):GetFirst()
    if tc then aux.GrantKeyword(e,tc,code) end  -- [まで] ターン終了時まで
  end)
  c:RegisterEffect(e1)
end
s.codes={EFFECT_ASSASSIN,EFFECT_LANCER,EFFECT_DOUBLE_CRUSH,EFFECT_CANNOT_BANISH,EFFECT_CANNOT_ATTACK}
function s.mode(tp)
  return Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3),aux.Stringid(id,4))
end
function s.target(tp) return Duel.SelectTarget(tp,Card.IsSigni,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil) end
