-- WXK01-004 応援の駄姫　グズ子
-- 【出】：あなたのデッキの一番上を公開する。それがレベルが奇数のシグニの場合、カードを２枚引く。
-- 【起】《ダウン》：あなたのトラッシュから＜トリック＞のシグニ１枚を対象とし、それをデッキの一番上に置く。
-- 【起】《ゲーム１回》ダイレクト《コインアイコン》《コインアイコン》：このターン、このルリグは自身のアタックによってダメージを３回与える。（対戦相手は３回まで【ガード】できる）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    -- 공개한 카드도 뽑는 2장에 든다(FAQ 2)
    local g=Duel.GetDecktopGroup(tp,1)
    local x=g:GetFirst()
    if not x then return end
    Duel.RevealCards(g)
    if x:IsSigni() and x:GetLevel()%2==1 then Duel.Draw(tp,2) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCost(aux.SelfDownCost)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:IsClass(0,RACE_TRICK) end,tp,LOCATION_TRASH,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      Duel.SendToDeckPosition(tc,1)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(2)
  e3:SetOperation(function(e,tp,eg)
    -- [の間] 「このターン」 대미지마다 가드할 수 있다(근사: FAQ 3은 처음에 몇 번 가드할지 정한다)
    local lc=e:GetHandler()
    local e1=Effect.CreateEffect(lc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_MULTI_DAMAGE)
    e1:SetValue(3)
    e1:SetReset(RESET_PHASE+PHASE_END)
    lc:RegisterEffect(e1)
  end)
  c:RegisterEffect(e3)
end
