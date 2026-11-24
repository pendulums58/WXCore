-- WDK08-L14 紅蓮の使い魔　清姫
-- 【自】：このシグニがアタックしたとき、以下の３つから１つを選ぶ。このシグニが血晶武装状態の場合、代わりに３つまで選ぶ。同じ選択肢を２回以上選んでもよい。
-- ①ターン終了時まで、対戦相手のすべてのシグニのパワーを－1000する。
-- ②対戦相手のシグニ１体を対象とし、それのパワーが4000以下の場合、それをバニッシュする。
-- ③カードを２枚引き、手札を２枚捨てる。
-- ライフバースト：カードを１枚引く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetTarget(s.tg)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_LIFEBURST)
  e2:SetOperation(function(e,tp) Duel.Draw(tp,1) end)
  c:RegisterEffect(e2)
end
-- 모드를 고르고(血晶武装状態면 3개까지, 같은 것 여러 번), ②마다 대상을 처리 직전에 함께 고른다(용어집: 対象)
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  local max=e:GetHandler():IsBloodArmed() and 3 or 1
  local modes={}
  repeat
    modes[#modes+1]=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
  until #modes>=max or not Duel.SelectYesNo(tp)
  -- 텍스트 위에서부터 차례로 처리한다(FAQ 2: ①①② 순서라면 －2000 뒤에 ②의 4000 이하 판정)
  table.sort(modes)
  local label=0
  for i=#modes,1,-1 do label=label*4+modes[i]+1 end  -- 4진수 자리마다 모드+1(0이면 끝)
  e:SetLabel(label)
  for _,m in ipairs(modes) do
    if m==1 then Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil) end
  end
end
function s.op(e,tp)
  local targets={}
  for tc in Duel.GetTargets():Iter() do targets[#targets+1]=tc end
  local ti=0
  local label=e:GetLabel()
  while label>0 do
    local m=label%4-1
    label=label//4
    if m==0 then
      for tc in Duel.GetMatchingGroup(Card.IsSigni,tp,0,LOCATION_SZONE,nil):Iter() do
        aux.AddPower(e,tc,-1000)  -- [まで] ターン終了時まで
      end
    elseif m==1 then
      ti=ti+1
      local tc=targets[ti]
      if tc and tc:IsRelateToEffect(e) and tc:GetPower()<=4000 then Duel.Banish(tc) end
    else
      Duel.Draw(tp,2)
      aux.Discard(tp,2)
    end
  end
end
