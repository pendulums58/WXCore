-- SP26-005 ピース・サイン（「Lostorage incited WIXOSS 5」 初回特典）
-- このアーツを使用する際、使用コストとして追加で《白》を支払ってもよい。
-- 以下の２つから１つを選ぶ。追加で《白》を支払っていた場合、代わりに２つまで選ぶ。
-- ①あなたの手札から＜怪異＞のシグニ１枚を場に出す。
-- ②ターン終了時まで、あなたの【レイヤー】を持つすべての＜怪異＞のシグニは「《レイヤーアイコン》【自】：このシグニが場を離れたとき、対戦相手のシグニ１体を対象とし、それを手札に戻す。」を得る。
local s,id=GetID()
-- 【レイヤー】을 가진 카드(근사: 카드 목록)
s.layer={}
for _,v in ipairs({1469,1470,1471,1474,1476,1479,1480,1481,1482,1483,2765,2867,2868,2922,2935,2936,6039,6066,6146,6172}) do s.layer[v]=true end
function s.kaii(x) return x:IsSigni() and x:IsClass(0,RACE_KAII) end
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local base=Duel.GetUseCost()
    local more=Duel.CanPayEna(tp,base.."{W}") and Duel.SelectYesNo(tp)
    if more then Duel.SetUseCost(base.."{W}") end
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,more and 2 or 1,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
  end)
  -- 위에서부터 처리한다. ①로 낸 것도 ②를 얻는다(FAQ 3). 처리할 때 장에 있는 것만(FAQ 4)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    if m&1~=0 then
      local h=Duel.GetMatchingGroup(s.kaii,tp,LOCATION_HAND,0,nil)
      if h:GetCount()>0 then Duel.PutOnField(Duel.SelectCards(tp,h,1,1):GetFirst(),tp) end
    end
    if m&2==0 then return end
    for x in Duel.GetMatchingGroup(function(y) return s.kaii(y) and s.layer[y:GetCode()] end,tp,LOCATION_SZONE,0,nil):Iter() do
      -- 《レイヤーアイコン》 능력: 이 시그니가 있는 동안 내 ＜怪異＞가 얻는다
      local g=Effect.CreateEffect(e:GetHandler())
      g:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
      g:SetDescription(aux.Stringid(id,2))
      g:SetCode(EVENT_LEAVE_FIELD)
      g:SetTarget(function(e2,tp2,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.SelectTarget(tp2,Card.IsSigni,tp2,0,LOCATION_SZONE,1,1,nil)
      end)
      g:SetOperation(function(e2,tp2)
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e2) then Duel.SendToHand(tc) end
      end)
      -- [まで] ターン終了時まで
      local e2=Effect.CreateEffect(e:GetHandler())
      e2:SetType(EFFECT_TYPE_FIELD)
      e2:SetCode(EFFECT_GRANT)
      e2:SetRange(LOCATION_SZONE)
      e2:SetTargetRange(LOCATION_SZONE,0)
      e2:SetTarget(function(e3,y) return s.kaii(y) end)
      e2:SetLabelObject(g)
      e2:SetReset(RESET_PHASE+PHASE_END)
      x:GrantEffect(e2)
    end
  end)
  c:RegisterEffect(e1)
end
