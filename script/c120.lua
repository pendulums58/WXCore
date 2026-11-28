-- PR-206 宿業の花嫁　アルフォウ（「selector infected WIXOSS-Re/verse- 」第２巻 付録）
-- 【自】：このルリグが対戦相手のライフクロス１枚をクラッシュしたとき、各プレイヤーは自分のデッキの上からカードを５枚トラッシュに置く。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_CRUSHED)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCondition(function(e,tp,eg,ep) return ep~=tp and Duel.GetCrusher()==e:GetHandler() end)
  -- 【ダブルクラッシュ】면 2번(FAQ 2). 크러시 1장마다 한 번으로 근사
  e1:SetOperation(function(e,tp,eg)
    for _=1,math.max(1,eg:GetCount()) do
      for p=0,1 do
        local g=Duel.GetDecktopGroup(p,5)
        if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
      end
    end
  end)
  c:RegisterEffect(e1)
end
