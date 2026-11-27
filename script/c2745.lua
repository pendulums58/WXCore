-- WX15-002 みらくるあーや！Ⅳ
-- 【自】：あなたのメインフェイズ開始時、あなたのデッキの上からカードを２枚見る。その中からカード１枚を【トラップ】としてあなたのシグニゾーンに設置してもよい。残りを好きな順番でデッキの一番下に置く。
-- 【出】ホログラフ《コインアイコン》《コインアイコン》：このゲームの間、このルリグは「【自】：対戦相手のセンタールリグ１体がアタックしたとき、対戦相手はあなたのデッキの一番上のカードが《トラップアイコン》を持つか持たないかを宣言する。あなたのデッキの一番上を公開する。宣言が外れた場合、そのアタックであなたはダメージを受けない。」を得る。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_PHASE_START+PHASE_MAIN)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
  e1:SetOperation(function(e,tp)
    local g=Duel.GetDecktopGroup(tp,2)
    if g:GetCount()==0 then return end
    Duel.ConfirmCards(tp,g)
    local x=Duel.SelectCards(tp,g,0,1):GetFirst()
    if x then Duel.SetTrap(x,tp) end
    local rest=g:Filter(function(c) return c:IsLocation(LOCATION_MDECK) end,nil)
    if rest:GetCount()>0 then Duel.SendToDeckBottom(Duel.SelectOrder(tp,rest),false) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetCoinCost(2)
  e2:SetOperation(function(e,tp)
    -- 「このゲームの間」 이 루리그가 얻는다(그로우하면 잃는다. FAQ 5)
    local h=e:GetHandler()
    local g=Effect.CreateEffect(h)
    g:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    g:SetDescription(aux.Stringid(id,0))
    g:SetCode(EVENT_ATTACK)
    g:SetRange(LOCATION_LRIG)
    g:SetCondition(function(e2,tp2,eg) local x=eg:GetFirst() return x:GetControler()~=tp2 and x:IsType(TYPE_LRIG) end)
    g:SetOperation(function(e2,tp2)
      local x=Duel.GetDecktopGroup(tp2,1):GetFirst()
      if not x then return end
      -- 상대가 선언: 예 = 《トラップアイコン》을 가진다
      local say=Duel.SelectYesNo(1-tp2)
      Duel.RevealCards(Group.CreateGroup(x))
      if say~=x:HasTrapIcon() then
        local e1=Effect.CreateEffect(e2:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_PREVENT_DAMAGE)
        e1:SetTargetRange(1,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp2)
      end
    end)
    h:GrantEffect(g)
  end)
  c:RegisterEffect(e2)
end
