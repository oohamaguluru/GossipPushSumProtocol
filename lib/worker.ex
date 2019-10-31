defmodule WA do
  use GenServer

  def start_link(opts,topo,algo) do
    GenServer.start_link(__MODULE__ ,[opts,topo,algo],name: String.to_atom(Integer.to_string(opts)))
  end
#   def handle_cast({:result,n,k},{state}) do
#     # IO.puts "thread #{state} woring from #{round(n)} to #{round(k)}"
#     Enum.map(round(n)..round(k), fn x -> cond do 
#                                                true -> vampire_factors(trunc(x)) 
#                                                end
      
#     end)
#     GenServer.cast(String.to_atom(Integer.to_string(0)),{:finish})
#     {:noreply, {state}}
#   end
def handle_cast({:receiverumor},{x,topo,algo,q,counter,s,w,p1,p2}) do
    # GenServer.cast(String.to_atom(Integer.to_string(0)),{:work, state})
    # r = Enum.random(q) 
    counter = cond do 
                counter == 0 -> GenServer.cast(String.to_atom(Integer.to_string(0)),{:end, x})
                                GenServer.cast(String.to_atom(Integer.to_string(x)),{:sendrumor})
                                counter+1
                counter < 10 ->  #IO.puts "received by  #{x} with #{counter}"
                                GenServer.cast(String.to_atom(Integer.to_string(x)),{:sendrumor})
                                counter+1
                true ->  #IO.puts "received by  #{x} with #{counter}"
                        # GenServer.stop(self(),:normal)
                        send(self(), :kill_me_pls)
                        # GenServer.cast(String.to_atom("super"),{:childterminate,x})
                        counter
    end 
    
    {:noreply, {x,topo,algo,q,counter,s,w,p1,p2}}
  end
  def handle_cast({:receiverumorP,as,aw},{x,topo,algo,q,counter,s,w,p1,p2}) do
    # GenServer.cast(String.to_atom(Integer.to_string(0)),{:work, state})
    # r = Enum.random(q)
   c= abs((s/w)-((s+as)/(w+aw)))
   ncounter = cond do
                counter == 0 -> GenServer.cast(String.to_atom(Integer.to_string(0)),{:end, x})
                                counter+ 1
        c < :math.pow(10,-10) and p2 < :math.pow(10,-10) and p1 < :math.pow(10,-10) -> 
                                              #  IO.puts "received by  #{x} with #{c} #{p2},#{p1}"
                                                send(self(), :kill_me_pls)
                                                counter
                true -> GenServer.cast(String.to_atom(Integer.to_string(x)),{:sendrumorP})
                end
    # if(ncounter == 3) do
    #     IO.puts "received by  #{x} with #{counter}"
    #     # Process.exit(self(),:normal)
        
    # else
        # IO.puts "received by  #{x} with #{counter} s is #{s+as} w is #{w+aw} "
        GenServer.cast(String.to_atom(Integer.to_string(x)),{:sendrumorP})
    # end
    {:noreply, {x,topo,algo,q,ncounter,s+as,w+aw,c,p1}}
  end
  def handle_cast({:sendrumorP},{x,topo,algo,q,counter,s,w,p1,p2}) do
    r = Enum.random(q)
    GenServer.cast(String.to_atom(Integer.to_string(r)),{:receiverumorP,s/2,w/2})
    #  GenServer.cast(String.to_atom(Integer.to_string(x)),{:sendrumorP})
     {:noreply, {x,topo,algo,q,counter,s/2,w/2,p1,p2}}
    end
  def handle_cast({:sendrumor},{x,topo,algo,q,counter,s,w,p1,p2}) do
    # GenServer.cast(String.to_atom(Integer.to_string(0)),{:work, state})
    if(List.last(q)) do
            r = Enum.random(q)
            # IO.puts "sending to neighbour #{r} by #{x}"
            # if (  ) do 
            #         IO.puts "its gossip"
            #     end
            if(Process.whereis(String.to_atom(Integer.to_string(r)))) do
                    GenServer.cast(String.to_atom(Integer.to_string(r)),{:receiverumor})
                end
            # if(counter < 11) do
                # IO.puts "sending from #{x} with #{counter} "
                GenServer.cast(String.to_atom(Integer.to_string(x)),{:sendrumor})
            # end
        end
        # cond do 
        #     algo == "gossip" ->  
        #                         
        #     algo == "push-sum" -> IO.puts "push sum"
        #     true -> IO.puts "enter correct algo"
        #             System.stop(0)
        #     end
    
    {:noreply, {x,topo,algo,q,counter,s,w,p1,p2}}
  end
  def handle_cast({:createfriends,n,layer},{x,topo,algo,q,counter,s,w,p1,p2}) do
    # GenServer.cast(String.to_atom(Integer.to_string(0)),{:work, state})
    p = getfrinds(x,n,layer,topo)
    GenServer.cast(String.to_atom(Integer.to_string(0)),{:finish})
    # IO.puts "my friends are #{p} by #{x}"
    # Enum.each(p,fn(y) -> IO.puts " i am #{y} friend of #{x}" end)
    {:noreply, {x,topo,algo,p,counter,s,w,p1,p2}}
  end

def handle_cast({:createfriends2D,n,xc,yc},{x,topo,algo,q,counter,s,w,p1,p2}) do
    # GenServer.cast(String.to_atom(Integer.to_string(0)),{:work, state})
    p = getrand2D(x,n,xc,yc)
    GenServer.cast(String.to_atom(Integer.to_string(0)),{:finish})
    # IO.puts "my friends are #{p} by #{x}"
    # Enum.each(p,fn(y) -> IO.puts " i am #{y} friend of #{x}" end)
    {:noreply, {x,topo,algo,p,counter,s,w,p1,p2}}
end
  
 def getfrinds(x,n,layer,topo) do 
    # p = Enum.map(x..x+3, fn x -> x+1 end)
    # # IO.puts "sending frineds to #{inspect(p)} by #{x}"
    # p
    p = cond do 
         topo == "line"  ->   getline(x,n)
         topo == "full"  ->   getfull(x,n)
         topo == "3Dtorus" -> get3D(x,n,layer)
         topo == "honeycomb" -> gethoney(x,n)
         topo == "randhoneycomb" -> getrhoney(x,n)
         true -> IO.puts "enter correct topology"
                 System.stop(0)    
    end
    p
  end
  def get3D(x,n,layer) do
    dr = layer*layer
    lay  = trunc((x-1)/dr)
    ie = x - (lay*dr)
    row = trunc((ie-1)/layer)
    col = rem((ie-1),layer)
    p = cond do 
            (row+1)==layer -> [1+((col*layer)+(lay*dr))]
            true -> [1+((row+1)+(col*layer)+(lay*dr))]
        end     
    q = cond do 
            row == 0 -> [1+((layer-1)+(col*layer)+(lay*dr))]
            true ->  [1+((row-1)+(col*layer)+(lay*dr))]
        end
    r = cond do 
            (col+1)==layer -> [1+(row+(lay*dr))]
            true -> [1+(row+((col+1)*layer)+(lay*dr))]
        end     
    s = cond do 
            col == 0 -> [1+(row+((layer-1)*layer)+(lay*dr))]
            true ->  [1+(row+((col-1)*layer)+(lay*dr))]
        end
    t = cond do 
            (lay+1)==layer -> [1+(row+(col*layer))]
            true -> [1+(row+(col*layer)+((lay+1)*dr))]
        end     
    u = cond do 
            lay == 0 ->  [1+(row+(col*layer)+((layer-1)*dr))]
            true ->  [1+(row+(col*layer)+((lay-1)*dr))]
        end
    # IO.puts " #{row},#{col},#{lay} ,#{x} -- friends #{p ++ q ++ r ++ s ++ t ++ u}"
    # Enum.each(p ++ q ++ r ++ s ++ t ++ u,fn(y) -> IO.puts " i am #{y} friend of #{x}" end)
    p ++ q ++ r ++ s ++ t ++ u
  end
  def getfull(x,n) do 
    numbers = 1..n
    p = Enum.to_list(numbers) -- [x]
    p
  end
  def getrand2D(x,n,xc,yc) do 
    p = Enum.reduce(1..n, [], 
                fn y, acc -> acc ++ cond do 
                                    y == x -> #IO.puts " same number match"
                                              []
    :math.sqrt(:math.pow(Enum.at(xc,x-1)-Enum.at(xc,y-1),2)+:math.pow(Enum.at(yc,x-1)-Enum.at(yc,y-1),2)) < 0.1 -> [y]
                                    true -> []
                                    end 
    end)
    # IO.puts " i am #{x} friend of #{inspect(p)}"
    # Enum.each(p,fn(y) -> IO.puts " i am #{y} friend of #{x}" end)
    p
  end
  def getline(x,n) do 
    p = cond do
        x==1 -> [x+1]
        x==n -> [x-1]
        true -> [x-1,x+1]
    end
    p
  end
   def gethoney(x,n) do 
   row = trunc((x-1)/6)
   col = rem((x-1),6)
   last = trunc((n-1)/6)
   p = cond do 
        row == last -> cond do 
                         rem(last,2) == 0 -> cond do 
                            col == 0 -> [((6*(row-1))+col)+1]
                            col == 5 -> [((6*(row-1))+col)+1]
                            rem(col,2) == 0 ->[((6*row)+col-1)+1,((6*(row-1))+col)+1]
                            true -> [((6*row)+col+1)+1,((6*(row-1))+col)+1]
                            end
                         true -> cond do 
                            col == 0 -> [((6*(row-1))+col)+1]
                            col == 5 -> [((6*(row-1))+col)+1]
                            rem(col,2) == 0 -> [((6*row)+col+1)+1,((6*(row-1))+col)+1]
                            true -> [((6*row)+col-1)+1,((6*(row-1))+col)+1]
                            end
                        end
        row == 0 ->  cond do 
                            col == 0 -> [((6*(row+1))+col)+1]
                            col == 5 -> [((6*(row+1))+col)+1]
                            rem(col,2) == 0 ->[((6*row)+col-1)+1,((6*(row+1))+col)+1]
                            true -> [((6*row)+col+1)+1,((6*(row+1))+col)+1]
                            end
        rem(row,2) == 0 -> cond do 
                            col == 0 -> [((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            col == 5 -> [((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            rem(col,2) == 0 ->[((6*row)+col-1)+1,((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            true -> [((6*row)+col+1)+1,((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            end
        true -> cond do 
                            col == 0 -> [((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            col == 5 -> [((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            rem(col,2) == 0 -> [((6*row)+col+1)+1,((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            true -> [((6*row)+col-1)+1,((6*(row-1))+col)+1,((6*(row+1))+col)+1]
                            end
    end
    # Enum.each(p,fn(y) -> IO.puts " i am #{y} friend of #{x}" end)
    p
  end
   def getrhoney(x,n) do 
    p = gethoney(x,n)
    numbers = 1..n
    t = Enum.to_list(numbers) -- [p]
    r = [Enum.random(t -- [x])]
    # Enum.each(r,fn(y) -> IO.puts " i am #{y} friend of #{x}" end)
    p ++ r 
  end
  def init(args) do
#   IO.puts "stated worker with #{inspect(args)}"
    counter = 0 
    x = Enum.at(args,0)
    s = x
    w= 1
    topo = Enum.at(args,1)
    algo = Enum.at(args,2)
    p1=1
    p2=1
    # IO.puts "have to use algo  #{inspect(algo)} by #{inspect(x)}"
    {:ok, {x,topo,algo,[],counter,s,w,p1,p2}}
  end

  def handle_info(:kill_me_pls, {x,topo,algo,p,counter,s,w,p1,p2}) do
     {:stop, :normal, {x,topo,algo,p,counter,s,w,p1,p2}}
   end

end