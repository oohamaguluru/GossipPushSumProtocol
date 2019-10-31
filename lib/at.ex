defmodule AT do
  use GenServer
  def start_link(n,algo) do
    GenServer.start_link(__MODULE__ ,[n,algo],name: String.to_atom(Integer.to_string(0)))
  end
#   def handle_call({:create},_from,{n,algo}) do
#     # x = List.flatten(Enum.map(p,fn(x) -> Enum.map(Tuple.to_list(x),fn(y)-> y end) end) )
#     # IO.puts(["#{inspect(q)} ", Enum.join(x, " ")])
#     IO.puts "crete friends for #{n} workes using #{algo} "
#     Enum.each(1..String.to_integer(n),fn(x) -> 
#                                 p = getfrinds(x,n,algo)
#                                 GenServer.cast(String.to_atom(Integer.to_string(x)),{:sendfriends,p}) end)
#     {:reply,"ok",{n,algo}}
#   end
#   def getfrinds(x,n,algo) do 
#     p = Enum.map(x..x+3, fn x -> x end)
#     # IO.puts "sending frineds to #{inspect(p)} by #{x}"
#     p
#   end
  def init(args) do
  # IO.puts "stated assigner with #{inspect(args)}"
    # threads = Enum.at(args,0)
    n = Enum.at(args,0)
    count = 0
    time = :os.system_time(:millisecond)
    algo = Enum.at(args,1)
    # IO.puts "algology to be used is #{inspect(algo)} by #{n} workers"
    {:ok, {n,algo,count,time}}
  end
   def handle_cast({:finish},{n,algo,count,time}) do
       time =  cond do
            n == count+1 ->   cond do 
                            algo == "gossip" -> r = Enum.random(Enum.to_list(1..n))
                                                GenServer.cast(String.to_atom(Integer.to_string(r)),{:sendrumor})
                                                :os.system_time(:millisecond)
                            algo == "push-sum" -> 
                                                r = Enum.random(Enum.to_list(1..n))
                                                GenServer.cast(String.to_atom(Integer.to_string(r)),{:sendrumorP})
                                                :os.system_time(:millisecond)
                            true -> IO.puts "enter correct algo"
                                    System.stop(0)
                            end
            true -> :os.system_time(:millisecond)
        end
      {:noreply, {n,algo,count+1,time}}
  end
  def handle_cast({:end,x},{n,algo,count,time}) do
        # IO.puts "heard full by #{x}  and stoped sending"
        cond do
            0 == count-1 -> IO.puts "finshed gossip in #{:os.system_time(:millisecond) - time} milliseconds"
                            System.stop(0)
            true -> count
                    # IO.puts " Heard rumor by #{x} and count is  #{n-count+1}"
        end
        # GenServer.stop(Process.whereis(String.to_atom(Integer.to_string(x))),:normal)
    {:noreply, {n,algo,count-1,time}}
    end
end