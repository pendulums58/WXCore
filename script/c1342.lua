-- WD22-011-G フーリッシュ・マイアズマ
-- 以下の４つから２つまで選ぶ。あなたのセンタールリグが＜グズ子＞の場合、代わりに３つまで選ぶ。
-- ①このターン、あなたのシグニ１体が効果によって場に出たとき、対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。
-- ②あなたのシグニ２体をバニッシュする。そうした場合、カードを２枚引く。
-- ③対戦相手のシグニ１体を対象とし、それのレベルがあなたの手札の枚数以下の場合、それをバニッシュする。
-- ④あなたのトラッシュからレベル３以下のシグニ１枚を対象とし、それを場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local modes,targets={},{}  -- 선언 때 고른 모드와 모드마다의 대상
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local lc=Duel.GetMatchingGroup(nil,tp,LOCATION_LRIG,0,nil):GetFirst()
    local max=lc and lc:IsLrigType(LRIG_GUZUKO) and 3 or 2
    modes={}
    for _,m in ipairs(Duel.SelectModes(tp,1,max,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))) do modes[m+1]=true end
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    targets={}
    if modes[3] then targets[3]=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst() end
    if modes[4] then targets[4]=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsLevelBetween(0,3) end,tp,LOCATION_TRASH,0,1,1,nil):GetFirst() end
  end)
  e1:SetOperation(function(e,tp)
    local t={}
    for i,tc in pairs(targets) do if tc:IsRelateToEffect(e) then t[i]=tc end end
    if modes[1] then s.watch(e,tp) end
    if modes[2] then
      local g=Duel.GetMatchingGroup(Card.IsSigni,tp,LOCATION_SZONE,0,nil)
      -- 다른 행동으로 바뀌어도 뽑는다(FAQ 2)
      if g:GetCount()>=2 and Duel.Banish(Duel.SelectCards(tp,g,2,2))==2 then Duel.Draw(tp,2) end
    end
    -- 패는 이때 센다(FAQ 4)
    if t[3] and t[3]:GetLevel()<=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil):GetCount() then Duel.Banish(t[3]) end
    if t[4] then Duel.PutOnField(t[4],tp) end
  end)
  c:RegisterEffect(e1)
end
-- [の間] 「このターン」 효과로 내 시그니가 나올 때마다. ④로 나온 것도(FAQ 5)
function s.watch(e,tp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetReset(RESET_PHASE+PHASE_END)
  e1:SetCondition(function(e,tp,eg,ep,ev,re,r)
    local x=eg:GetFirst()
    return x:IsSigni() and x:GetControler()==tp and (r&REASON_EFFECT)~=0
  end)
  e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil)
  end)
  e1:SetOperation(function(e1,tp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e1) then aux.AddPower(e,tc,-7000) end  -- [まで] ターン終了時まで
  end)
  Duel.RegisterEffect(e1,tp)
end
