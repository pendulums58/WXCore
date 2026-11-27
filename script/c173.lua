-- WX20-Re20 バニラ・スクランブル
-- 以下の２つから２つまで選ぶ。選んだ数が２つの場合、このアーツの使用コストは《無×2》増える。
-- ①あなたのデッキから能力を持たないシグニを３枚まで探して公開し手札に加え、デッキをシャッフルする。
-- ②あなたの手札から能力を持たないシグニを好きな枚数場に出す。ターン終了時、それらを場からトラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetDeclare(function(e,tp)
    local m=0
    for _,i in ipairs(Duel.SelectModes(tp,1,2,aux.Stringid(id,0),aux.Stringid(id,1))) do m=m|(1<<i) end
    e:SetLabel(m)
    if m==3 then Duel.SetUseCost(Duel.GetUseCost().."{C}{C}") end
  end)
  e1:SetOperation(function(e,tp)
    local m=e:GetLabel()
    local noabi=function(x) return x:IsSigni() and not x:HasAbility() end
    if m&1~=0 then aux.SearchToHand(tp,noabi,3) end
    if m&2~=0 then
      local g=Duel.SelectCards(tp,Duel.GetMatchingGroup(noabi,tp,LOCATION_HAND,0,nil),0,3)
      local out=Group.CreateGroup()
      for x in g:Iter() do if Duel.PutOnField(x,tp) then out:AddCard(x) end end
      if out:GetCount()>0 then
    local e9=Effect.CreateEffect(e:GetHandler())
        e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
        e9:SetCode(EVENT_TURN_END)
        e9:SetOperation(function() local g=out:Filter(function(x) return x:IsLocation(LOCATION_SZONE) end,nil) if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end end)
        e9:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e9,tp)
      end
    end
  end)
  c:RegisterEffect(e1)
end
