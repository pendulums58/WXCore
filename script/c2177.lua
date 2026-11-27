-- WX07-006 白羅星　サタン
-- 【出現条件】 《メインフェイズアイコン》レベルの合計が７以上になるようにレゾナではない＜宇宙＞のシグニ３体をあなたの場からトラッシュに置く
-- 【常】：対戦相手はシグニを２体までしか場に出すことができない。（すでに場に３体ある場合は２体になるようにシグニをトラッシュに置く）
local s,id=GetID()
function s.initial_effect(c)
  -- 레벨 합계 7 이상(FAQ 1)
  aux.AddResonaProc(c,3,aux.NonResonaClass(RACE_UCHU),nil,nil,nil,function(g)
    local n=0
    for x in g:Iter() do n=n+x:GetLevel() end
    return n>=7
  end)
  -- [の間] 【常】 넘으면 상대가 골라 트래시(FAQ 2). アルテマ와 같이면 1체(FAQ 4)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_SIGNI_LIMIT)
  e1:SetRange(LOCATION_SZONE)
  e1:SetTargetRange(0,1)
  e1:SetValue(2)
  c:RegisterEffect(e1)
end
