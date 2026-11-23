-- WD19-018 ラブリー・バイオ
-- 以下の２つから１つを選ぶ。
-- ①あなたの＜微菌＞のシグニ１体を対象とし、それをバニッシュする。そうした場合、対戦相手のシグニゾーン１つに【ウィルス】１つを置く。
-- ②対象のあなたの＜微菌＞のシグニ１体をバニッシュする。そうした場合、ターン終了時まで、対象の対戦相手のシグニ１体のパワーを－7000する。
local s,id=GetID()
s.germ=aux.ClassFilter(0,RACE_BIKIN)  -- ＜微菌＞のシグニ
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
end
-- 모드를 고른 뒤 처리 직전에 대상을 고른다. ②는 내 시그니와 상대 시그니를 함께 고른다(FAQ 1)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local mode=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
  e:SetLabel(mode)
  Duel.SelectTarget(tp,s.germ,tp,LOCATION_SZONE,0,1,1,nil)
  if mode==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
end
function s.op(e,tp)
  local mine, opp
  for tc in Duel.GetTargets():Iter() do
    if tc:GetControler()==tp then mine=mine or tc else opp=opp or tc end
  end
  -- 「そうした場合」: 내 ＜微菌＞을 바니시하지 못하면 뒷부분은 하지 않는다
  if not (mine and mine:IsRelateToEffect(e) and Duel.Banish(mine)>0) then return end
  if e:GetLabel()==0 then
    local zones={}
    for _,z in ipairs(Duel.GetSigniZones(1-tp)) do
      if not Duel.HasVirus(z) then zones[#zones+1]=z end
    end
    local z=Duel.SelectZone(tp,zones)
    if z then Duel.PlaceVirus(z) end
  elseif opp and opp:IsRelateToEffect(e) then
    -- [まで] ターン終了時まで
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_POWER)
    e1:SetValue(-7000)
    e1:SetReset(RESET_PHASE+PHASE_END)
    opp:RegisterEffect(e1)
  end
end
