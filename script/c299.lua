-- PR-471 相手ルリグ全員タマに憧れてる説（ウィクロス ぶくぶタマ劇場 第１巻 付録）
-- このゲームの間、すべての場にあるセンタールリグは＜ぶくぶタマ＞を追加で得る。以下の３つから対戦相手のセンタールリグのルリグタイプ１つにつき１つまで選ぶ。
-- ①次の対戦相手のターンの間、対戦相手のルリグはあなたにダメージを与えない。
-- ②次の対戦相手のターンの間、対戦相手は無色ではない、アーツとスペルを使用できない。
-- ③あなたのデッキから無色のシグニを２枚まで探して公開し手札に加え、デッキをシャッフルする。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 둘 다 얻고 그로우해도 계속(FAQ 1·2). 같은 타입은 하나(FAQ 3). 모드는 상대 루리그 타입 수까지(FAQ 4)
  e1:SetOperation(function(e,tp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_ADD_LRIG_TYPE)
    e1:SetTargetRange(LOCATION_LRIG,LOCATION_LRIG)
    e1:SetValue(LRIG_BUKUBUTAMA)
    Duel.RegisterEffect(e1,tp)
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    local n=oc and math.min(3,#oc:GetLrigTypes()) or 0
    if n==0 then return end
    local now=Duel.GetTurnCount()
    local nextopp=function() return Duel.GetTurnCount()==now+1 end
    for _,m in ipairs(Duel.SelectModes(tp,0,n,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))) do
      if m==2 then
        local g=aux.Search(tp,function(x) return x:IsSigni() and x:GetColor()==0 end,2)
        if g:GetCount()>0 then
          Duel.RevealCards(g)
          Duel.SendToHand(g)
        end
        aux.ShuffleDeck(tp)
      else
        -- [の間] 次の対戦相手のターンの間
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD)
        if m==0 then
          e2:SetCode(EFFECT_NO_LRIG_DAMAGE)
          e2:SetTargetRange(1,0)
        else
          e2:SetCode(EFFECT_CANNOT_USE)
          e2:SetTargetRange(0,1)
          e2:SetTarget(function(e3,x) return (x:IsType(TYPE_ARTS) or x:IsType(TYPE_SPELL)) and x:GetColor()~=0 end)
        end
        e2:SetCondition(nextopp)
        e2:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e2,tp)
      end
    end
  end)
  c:RegisterEffect(e1)
end
