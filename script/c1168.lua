-- WD08-008 アンシエント・リターン
-- あなたのデッキの上からカードを５枚トラッシュに置く。この方法でトラッシュに置いたカードの中に、共通するクラスを持つカードが３枚以上ある場合、
-- そのクラス１つを選択する。その後、あなたのトラッシュから選択したクラスを持つシグニを２枚まで対象とし、それらを手札に加える。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
function s.op(e,tp)
  local g=Duel.GetDecktopGroup(tp,5)
  if g:GetCount()==0 then return end
  Duel.SendToTrash(g,REASON_EFFECT)
  local cnt={}
  for x in g:Iter() do
    if x:IsLocation(LOCATION_TRASH) then
      for _,cls in ipairs(x:GetClasses()) do cnt[cls]=(cnt[cls] or 0)+1 end
    end
  end
  local function ok(x)
    for _,cls in ipairs(x:GetClasses()) do if (cnt[cls] or 0)>=3 then return true end end
    return false
  end
  -- 클래스 선택: 조건을 채운 클래스가 여럿이면 그 클래스를 가진 카드 1장을 골라 정한다
  local cands=g:Filter(function(x) return x:IsLocation(LOCATION_TRASH) and ok(x) end,nil)
  if cands:GetCount()==0 then return end
  local pick=cands:GetFirst()
  if cands:GetCount()>1 then pick=Duel.SelectCards(tp,cands,1,1):GetFirst() end
  local cls
  for _,k in ipairs(pick:GetClasses()) do
    if (cnt[k] or 0)>=3 then cls=k break end
  end
  local function has(x)
    if not x:IsSigni() then return false end
    for _,k in ipairs(x:GetClasses()) do if k==cls then return true end end
    return false
  end
  for tc in Duel.SelectTarget(tp,has,tp,LOCATION_TRASH,0,0,2,nil):Iter() do Duel.SendToHand(tc) end
end
