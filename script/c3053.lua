-- WX19-026 幻水姫　カラードカープ
-- 【自】《ターン１回》：このシグニがアタックしたとき、カード名１つを宣言する。対戦相手はデッキの一番上を公開する。それが宣言したカードの場合、それをトラッシュに置き、このシグニをアップする。
-- 【自】：あなたの＜水獣＞のシグニ１体が対戦相手の効果によって場を離たとき、カードを１枚引いてもよい。
-- ライフバースト：どちらか１つを選ぶ。①カードを１枚引く。②対戦相手のレベル３以下のシグニ１体を対象とし、それをデッキの一番上に置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ATTACK)
  e1:SetCountLimit(1)
  e1:SetOperation(function(e,tp)
    local cid=Duel.AnnounceCard(tp)
    local x=Duel.GetDecktopGroup(1-tp,1):GetFirst()
    if not x then return end
    Duel.RevealCards(Group.CreateGroup(x))
    if x:IsCardName(cid) then
      Duel.SendToTrash(x,REASON_EFFECT)
      local h=e:GetHandler() if h:IsLocation(LOCATION_SZONE) then Duel.Up(h) end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_LEAVE_FIELD)
  e2:SetRange(LOCATION_SZONE)
  e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) local x=eg:GetFirst() return x:GetOwner()==tp and (function(x) return x:IsSigni() and (x:IsClass(0,RACE_SUIJU)) end)(x) and r&REASON_EFFECT~=0 and rp~=tp end)
  e2:SetOperation(function(e,tp)
    if Duel.SelectYesNo(tp) then Duel.Draw(tp,1) end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_LIFEBURST)
  e3:SetDeclare(function(e,tp)
    e:SetLabel(Duel.SelectModes(tp,1,1,aux.Stringid(id,0),aux.Stringid(id,1))[1])
  end)
  e3:SetOperation(function(e,tp)
    if e:GetLabel()==0 then Duel.Draw(tp,1) return end
    local tc=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:GetLevel()<=3 end,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
    if tc then Duel.SendToDeckPosition(tc,1) end
  end)
  c:RegisterEffect(e3)
end
