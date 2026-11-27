-- WX12-037 堕落の砲娘　メツミ
-- 【常】：あなたのトラッシュにカードが２５枚以上あるかぎり、このシグニの基本パワーは12000になり、このシグニはバニッシュされない。
-- 【出】：各プレイヤーは自分のデッキの上からカードを５枚トラッシュに置く。この方法でトラッシュに置いたカードの中にカード名に《メツム》を含むカードがある場合、あなたはこの効果を繰り返してもよい。（リフレッシュはこの効果をすべて処理してから行う）
local s,id=GetID()
function s.initial_effect(c)
  -- [の間] 【常】
  aux.BasePower(c,12000,function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=25 end)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE)
  e1:SetDescription(aux.Ability(id,0))
  e1:SetCode(EFFECT_CANNOT_BANISH)
  e1:SetRange(LOCATION_SZONE)
  e1:SetCondition(function(e) return Duel.GetMatchingGroup(nil,e:GetHandlerPlayer(),LOCATION_TRASH,0,nil):GetCount()>=25 end)
  c:RegisterEffect(e1)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
  e2:SetDescription(aux.Ability(id,1))
  e2:SetCode(EVENT_ON_PLAY)
  e2:SetOperation(function(e,tp)
    for _=1,20 do
      local hit=false
      for _,p in ipairs({tp,1-tp}) do
        local g=Duel.GetDecktopGroup(p,5)
        if g:GetCount()>0 then
          Duel.SendToTrash(g,REASON_EFFECT)
          if g:Filter(function(x) return aux.NameHas(x,"メツム") end,nil):GetCount()>0 then hit=true end
        end
      end
      if not (hit and Duel.SelectYesNo(tp)) then break end
    end
  end)
  c:RegisterEffect(e2)
end
