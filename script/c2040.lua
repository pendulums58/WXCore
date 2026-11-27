-- WX04-063 ゲット・ゲート
-- このスペルの使用コストで支払われたエナ１つにつきそのエナの色１つを選択する。あなたのデッキから、選択した色の種類１つにつきその色を持つシグニ１枚を探して公開し手札に加え、デッキをシャッフルする。（《白》、《無》、【マルチエナ】で支払われた場合、最大で白のシグニ１枚と白ではない色のシグニ１枚の合計２枚を手札に加えることができる。無色は色に含まれない）
local s,id=GetID()
function s.initial_effect(c)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetDescription(aux.Ability(id,0))
  -- 낸 에나마다 그 색 하나. 【マルチエナ】는 어느 색이든. 무색은 색이 아니다(FAQ 1·2)
  e1:SetOperation(function(e,tp)
    local names={[COLOR_WHITE]=0,[COLOR_RED]=1,[COLOR_BLUE]=2,[COLOR_GREEN]=3,[COLOR_BLACK]=4}
    local chosen={}
    for x in Duel.GetPaidEna():Iter() do
      local opts={}
      for col,i in pairs(names) do
        if x:IsColor(col) or x:HasKeyword(EFFECT_MULTI_ENA) then opts[#opts+1]=col end
      end
      if #opts==1 then
        chosen[opts[1]]=true
      elseif #opts>1 then
        local labels={}
        for i,col in ipairs(opts) do labels[i]=aux.Stringid(id,names[col]) end
        chosen[opts[Duel.SelectOption(tp,table.unpack(labels))+1]]=true
      end
    end
    local cols={}
    for col in pairs(chosen) do cols[#cols+1]=col end
    if #cols==0 then
      aux.ShuffleDeck(tp)
      return
    end
    -- 색마다 1장. 고른 묶음이 색에 하나씩 맞춰져야 한다
    Duel.SetSelectCheck(function(sg)
      local l={}
      for x in sg:Iter() do l[#l+1]=x end
      local used={}
      local function try(i)
        if i>#l then return true end
        for _,col in ipairs(cols) do
          if not used[col] and l[i]:IsColor(col) then
            used[col]=true
            if try(i+1) then return true end
            used[col]=nil
          end
        end
        return false
      end
      return try(1)
    end)
    local g=aux.Search(tp,function(x)
      if not x:IsSigni() then return false end
      for _,col in ipairs(cols) do if x:IsColor(col) then return true end end
      return false
    end,#cols)
    if g:GetCount()>0 then
      Duel.RevealCards(g)
      Duel.SendToHand(g)
    end
    aux.ShuffleDeck(tp)
  end)
  c:RegisterEffect(e1)
end
