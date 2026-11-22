-- WXDi-D01-011 ハーモニー・コール (ピース)
-- 【使用条件】【チーム】＜アンシエント･サプライズ＞＆全員レベル１以上
-- あなたのデッキの上からカードを８枚見る。その中からレベル１とレベル２とレベル３のシグニをそれぞれ１枚まで場に出し、
-- 残りをシャッフルしてデッキの一番下に置く。その後、ターン終了時まで、対象のレベル１のシグニ１体は【アサシン】を得、
-- 対象のレベル２のシグニ１体は【ダブルクラッシュ】を得、対象のレベル３のシグニ１体は【ランサー】を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCondition(s.con)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.con(e,tp)
  if not Duel.IsTeam(tp,"アンシエント・サプライズ") then return false end
  for c in Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG+LOCATION_ASSIST,0,nil):Iter() do
    if c:GetLevel()<1 then return false end
  end
  return true
end
function s.lv(n) return function(c) return c:IsSigni() and c:GetLevel()==n end end
s.grants={EFFECT_ASSASSIN,EFFECT_DOUBLE_CRUSH,EFFECT_LANCER}
function s.op(e,tp)
  -- 덱이 8장보다 적으면 남은 만큼 본다(FAQ 5)
  local g=Duel.GetDecktopGroup(tp,8)
  Duel.ConfirmCards(tp,g)
  local put=Group.CreateGroup()
  for lv=1,3 do
    local cands=g:Filter(function(c) return s.lv(lv)(c) and not put:IsContains(c) end,nil)
    local c=Duel.SelectCards(tp,cands,0,1):GetFirst()
    -- 빈 시그니 존에만 낼 수 있다(FAQ 4)
    if c and Duel.PutOnField(c,tp) then put:AddCard(c) end
  end
  local rest=Group.CreateGroup()
  for c in g:Iter() do if not put:IsContains(c) then rest:AddCard(c) end end
  Duel.SendToDeckBottom(rest,true)
  -- 피스 전부터 장에 있던 시그니도 대상으로 할 수 있다(FAQ 2)
  for lv=1,3 do
    local tc=Duel.SelectTarget(tp,s.lv(lv),tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
    if tc then
      -- [まで] ターン終了時まで
      local e1=Effect.CreateEffect(e:GetHandler())
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(s.grants[lv])
      e1:SetReset(RESET_PHASE+PHASE_END)
      tc:GrantEffect(e1)
    end
  end
end
