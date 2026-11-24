-- WDK06-C09 ナナシ　其の鉤
-- 【出】：各プレイヤーは自分のデッキの上からカードを５枚トラッシュに置く。
-- 【起】《ターン１回》《黒》《黒》：あなたのトラッシュからあなたのセンタールリグと共通する色を持つシグニ１枚を対象とし、それを手札に加える。
-- 【起】《アタックフェイズアイコン》このキーを場からルリグトラッシュに置く：ターン終了時まで、対戦相手のすべてのシグニのパワーを対戦相手のセンタールリグのレベル１につき－2000する。（この能力を使用した後に場に出たシグニはこの効果の影響を受けない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,5)
    for x in Duel.GetDecktopGroup(1-tp,5):Iter() do g:AddCard(x) end
    if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_KEY)
  e2:SetCountLimit(1)
  e2:SetEnaCost("{B}{B}")
  -- 코스트를 낸 뒤에 고른다(FAQ 2). 무색끼리는 공통된 색이 없다(FAQ 3)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local col=lc and lc:GetColor() or 0
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetColor()&col~=0 end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then Duel.SendToHand(tc) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_KEY)
  e3:SetTiming(TIMING_ATTACK)
  e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsLocation(LOCATION_KEY) end
    Duel.SendToLrigTrash(e:GetHandler(),REASON_COST)
  end)
  -- [まで] 처리할 때 장에 있는 시그니만
  e3:SetOperation(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if not lc then return end
    for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
      aux.AddPower(e,tc,-2000*lc:GetLevel())
    end
  end)
  c:RegisterEffect(e3)
end
