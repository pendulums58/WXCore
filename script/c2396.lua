-- WX10-019 緑参ノ遊　カップ
-- 【出現条件】 《メインフェイズアイコン》レゾナではない＜遊具＞のシグニ２体をあなたの場からトラッシュに置く
-- 【出】：あなたのデッキから＜遊具＞のシグニ１枚を探して場に出し、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  aux.AddResonaProc(c,2,aux.NonResonaClass(RACE_YUGU))
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,1))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetOperation(function(e,tp)
    local x=aux.Search(tp,function(x) return x:IsSigni() and (x:IsClass(0,RACE_YUGU)) end,1):GetFirst()
    if x then Duel.PutOnField(x,tp) end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
