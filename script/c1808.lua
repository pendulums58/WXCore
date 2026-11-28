-- WDK17-001 黒幕の舞姫　アルフォウ
-- 【自】《ターン１回》：あなたの傀儡状態のシグニ１体が場に出たとき、以下の３つから１つを選ぶ。①対戦相手のシグニ１体を対象とし、ターン終了時まで、それのパワーを－7000する。②カードを１枚引く。③各プレイヤーは自分のデッキの上からカードを３枚トラッシュに置く。
-- 【起】《ゲーム１回》ジェラシー《コインアイコン》：このゲームの間、このルリグは対戦相手のセンタールリグのルリグタイプを追加で得る。対戦相手のトラッシュからシグニ１枚を対象とし、それを傀儡状態であなたの場に出す。
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EVENT_ON_PLAY)
  e1:SetRange(LOCATION_LRIG)
  e1:SetCountLimit(1)
  e1:SetCondition(function(e,tp,eg) local x=eg:GetFirst() return x:IsSigni() and x:GetControler()==tp and x:IsPuppet() end)
  e1:SetOperation(function(e,tp)
    local m=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
    if m==0 then
      local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_SZONE,1,1,nil):GetFirst()
      if tc then aux.AddPower(e,tc,-7000) end  -- [まで] ターン終了時まで
    elseif m==1 then
      Duel.Draw(tp,1)
    else
      for p=0,1 do
        local g=Duel.GetDecktopGroup(p,3)
        if g:GetCount()>0 then Duel.SendToTrash(g,REASON_EFFECT) end
      end
    end
  end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_IGNITION)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetRange(LOCATION_LRIG)
  e2:SetCountLimit(1,true)
  e2:SetCoinCost(1)
  -- 「このゲームの間」 이 루리그가 얻는다. 그로우하면 잃는다(FAQ 5). 루리그 타입을 얻은 뒤에 고른다(FAQ 1)
  e2:SetOperation(function(e,tp)
    local h=e:GetHandler()
    local oc=Duel.GetMatchingGroup(nil,tp,0,LOCATION_LRIG,nil):GetFirst()
    if oc and h then
      for _,lt in ipairs(oc:GetLrigTypes()) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_ADD_LRIG_TYPE)
        e1:SetValue(lt)
        h:RegisterEffect(e1)
      end
    end
    local tc=Duel.SelectTarget(tp,Card.IsSigni,tp,0,LOCATION_TRASH,1,1,nil):GetFirst()
    if tc then Duel.PutOnField(tc,tp) end
  end)
  c:RegisterEffect(e2)
end
