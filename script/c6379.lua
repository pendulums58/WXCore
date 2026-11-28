-- WXK03-003A 夢限　-Ｐ-
-- このカードをルリグデッキに入れる場合、あなたのルリグデッキにはアーツを３枚までしか入れられない
-- 【常】：あなたはキーを好きな枚数場に出すことができる。
-- 【起】《ターン１回》《無》：《コインアイコン》を得る。このゲームの間、あなたの場にある《夢限　-Ｐ-》の基本レベルと基本リミットは、対象の対戦相手のセンタールリグ１体と同じ値になる。このゲームの間にあなたがこの【起】を使用したのが５回目である場合、このルリグを裏返す。
local s,id=GetID()
s.used={}  -- 이 게임에서 【起】를 쓴 횟수(플레이어별)
function s.initial_effect(c)
  -- 【常】「キーを好きな枚数場に出す」는 아직(키 존이 하나)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetDescription(aux.Ability(id,2))
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetEnaCost("{C}")
  e1:SetOperation(function(e,tp,eg)
    Duel.AddCoin(tp,1)
    local h=e:GetHandler()
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if oc then
      -- [まで] 「このゲームの間」 쓴 때의 값(FAQ 4)
      local lv,lim=oc:GetLevel(),oc:GetLimit()
      local e1=Effect.CreateEffect(h)
      e1:SetType(EFFECT_TYPE_SINGLE)
      e1:SetCode(EFFECT_CHANGE_LEVEL)
      e1:SetValue(lv)
      h:RegisterEffect(e1)
      local e2=Effect.CreateEffect(h)
      e2:SetType(EFFECT_TYPE_SINGLE)
      e2:SetCode(EFFECT_UPDATE_LIMIT)
      e2:SetValue(lim-h:GetLimit())
      h:RegisterEffect(e2)
    end
    s.used[tp]=(s.used[tp] or 0)+1
    if s.used[tp]<5 then return end
    -- 「このルリグを裏返す」: 《夢限　-Ｅ-》를 만들어 그로우하는 것으로 근사. 루리그 트래시의 아츠를 아래에(-E-의 【自】)
    local back=Duel.AddCraft(6380,tp)
    if back and Duel.GrowByEffect(back,tp) then
      local a=Duel.GetMatchingGroup(function(x) return x:IsType(TYPE_ARTS) end,tp,LOCATION_LTRASH,0,nil)
      if a:GetCount()>0 then Duel.PutUnder(back,a) end
    end
  end)
  c:RegisterEffect(e1)
end
