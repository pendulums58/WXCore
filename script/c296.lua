-- PR-469 五体合体　グレートタマヨリオー（コロコロアニキ2019年春号 付録）
-- 【グロウ】あなたのルリグデッキにある＜タマ＞のルリグ５枚をゲームから除外する
-- 【常】：レベル０のルリグからこのルリグにグロウできる。
-- 【常】：あなたはアーツとスペルを使用できない。
-- 【起】《メインフェイズアイコン》《アタックフェイズアイコン》《白》《白》《白》ルリグデッキにある＜タマ＞のルリグ１枚をゲームから除外する：以下の３つからこの【起】能力でまだ選ばれていない１つを選ぶ。①対戦相手のすべてのシグニをトラッシュに置く。②対戦相手のデッキからすべてのカードをトラッシュに置く。③対戦相手のルリグデッキからカードを１枚見ないで選び公開する。それがルリグでない場合、それをルリグトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  -- 【グロウ】 루리그 덱의 ＜タマ＞ 루리그 5장을 게임에서 제외
  local e0=Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_GROW_PROC)
  e0:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) and x:IsLrigType(LRIG_TAMA) end,tp,LOCATION_LDECK,0,e:GetHandler())
    if chk==0 then return g:GetCount()>=5 end
    Duel.Exclude(Duel.SelectCards(tp,g,5,5))
  end)
  c:RegisterEffect(e0)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  -- [の間] 【常】 레벨 0에서 그로우
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EFFECT_GROW_LEVEL_FREE)
  e1:SetValue(0)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD)
  -- [の間] 【常】 피스는 쓸 수 있다(FAQ 1)
  e2:SetDescription(aux.Ability(id,2))
  e2:SetCode(EFFECT_CANNOT_USE)
  e2:SetRange(LOCATION_LRIG)
  e2:SetTargetRange(1,0)
  e2:SetTarget(function(e,x) return x:IsType(TYPE_ARTS) or x:IsType(TYPE_SPELL) end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,3))
  e3:SetRange(LOCATION_LRIG)
  e3:SetTiming(TIMING_MAIN+TIMING_ATTACK)
  e3:SetEnaCost("{W}{W}{W}")
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_LRIG) and x:IsLrigType(LRIG_TAMA) end,tp,LOCATION_LDECK,0,nil)
    if chk==0 then return g:GetCount()>0 and e:GetLabel()~=7 end
    Duel.Exclude(Duel.SelectCards(tp,g,1,1))
  end)
  -- 이 【起】로 아직 고르지 않은 것(e의 라벨에 고른 모드를 쌓는다). 피스는 루리그가 아니다(FAQ 2)
  e3:SetOperation(function(e,tp)
    local used=e:GetLabel()
    local opts,map={},{}
    for i=0,2 do
      if used&(1<<i)==0 then opts[#opts+1]=aux.Stringid(id,i) map[#map+1]=i end
    end
    if #opts==0 then return end
    local m=map[Duel.SelectOption(tp,table.unpack(opts))+1]
    e:SetLabel(used|(1<<m))
    if m==0 then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    elseif m==1 then
      local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MDECK,nil)
      if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
    else
      local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LDECK,nil)
      local x=g:GetCount()>0 and Duel.SelectCards(tp,g,1,1):GetFirst()
      if not x then return end
      Duel.RevealCards(Group.CreateGroup(x))
      if not x:IsType(TYPE_LRIG) then Duel.SendToLrigTrash(x,REASON_EFFECT) end
    end
  end)
  c:RegisterEffect(e3)
end
