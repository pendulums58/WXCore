-- WXK02-002 真情の記憶　リル
-- 【出】：あなたのトラッシュから《ライズアイコン》を持つシグニ１枚と＜アーム＞のシグニ１枚を対象とし、それらを手札に加える。
-- 【起】《ターン１回》《赤×0》：《ライズアイコン》を持つあなたのシグニ１体を対象とし、ターン終了時まで、それは【ダブルクラッシュ】を得る。
-- 【起】《ゲーム１回》オーネスト《コインアイコン》：対戦相手は数字１つを宣言する。ターン終了時、このターンに対戦相手が使用したアーツの回数が宣言した数字と異なる場合、対戦相手はゲームに敗北する。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp,eg)
    -- 한쪽만 있어도(FAQ 1)
    local a=Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_TRASH,0,0,1,nil):GetFirst()
    local b=Duel.SelectTarget(tp,function(x) return (function(x) return x:IsSigni() and x:IsClass(0,RACE_ARM) end)(x) and x~=a end,tp,LOCATION_TRASH,0,0,1,nil):GetFirst()
    local g=Group.CreateGroup()
    if a then g:AddCard(a) end
    if b then g:AddCard(b) end
    if g:GetCount()>0 then Duel.SendToHand(g) end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1)
  e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SelectTarget(tp,function(x) return x:IsSigni() and x:HasRiseIcon() end,tp,LOCATION_SZONE,0,1,1,nil)
  end)
  e2:SetOperation(function(e,tp,eg)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
      aux.GrantKeyword(e,tc,EFFECT_DOUBLE_CRUSH)
    end
  end)
  c:RegisterEffect(e2)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_IGNITION)
  e3:SetDescription(aux.Ability(id,2))
  e3:SetRange(LOCATION_LRIG)
  e3:SetCountLimit(1,true)
  e3:SetCoinCost(1)
  e3:SetOperation(function(e,tp,eg)
    -- 0도 선언할 수 있다(FAQ 3). 「ターンを終了する」로 끝나면 트리거하지 않는다(FAQ 5)
    local n=Duel.AnnounceNumber(1-tp,0,10)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_TURN_END)
    e1:SetOperation(function() if Duel.GetArtsUsedCount(1-tp)~=n then Duel.Lose(1-tp) end end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
  end)
  c:RegisterEffect(e3)
end
