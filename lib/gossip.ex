defmodule Gossip do
   use Supervisor
   def start_link(n,topo,algo) do
    # threads = readthreadsdata()
    # numNodes = 10#getnumnodes(n,topo)
    n = getnumnodes(n,topo)
    result = Supervisor.start_link(__MODULE__,[n,topo,algo],name: String.to_atom("super"))
    startchild(n,topo,algo)
    result
  end
    def init(args) do
     children = Enum.map(0..Enum.at(args,0), fn x -> cond do 
                                                    x == 0 -> worker(AT,[Enum.at(args,0),Enum.at(args,2)],[id: x,restart: :temporary]) # assign neighbours using topolgy worker
                                                    true -> worker(WA,[x,Enum.at(args,1),Enum.at(args,2)],[id: x,restart: :temporary]) # each one is a new worker who does work based on algo
                                               end
      
    end)
    # IO.puts "#{inspect(children)}"
        Supervisor.init(children,strategy: :one_for_one,restart: :temporary)
    end
    def getnumnodes(n,topo) do
        n = cond  do 
           topo == "3Dtorus" -> round(:math.pow(round(nth_root(3,String.to_integer(n))),3))
          true ->  String.to_integer(n)
        end    
        n
    end
    def nth_root(n, x, precision \\ 1.0e-5) do
        f = fn(prev) -> ((n - 1) * prev + x / :math.pow(prev, (n-1))) / n end
        fixed_point(f, x, precision, f.(x))
  end
   defp fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next
  defp fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))
    
def startchild(n,topo,algo) do
        # GenServer.call(String.to_atom(Integer.to_string(0)),{:createfriends})

        # threads = readthreadsdata()
        # n = Enum.at(threads,0)
       cond do 
        topo == "rand2D" ->
            xc = Enum.map(1..n,fn(x) -> Enum.random(1..n)/n end)
            yc = Enum.map(1..n,fn(x) -> Enum.random(1..n)/n end)
            # IO.puts "xc are #{inspect(xc)} and yc are #{inspect(yc)}"
            Enum.each(1..n,fn(x) -> GenServer.cast(String.to_atom(Integer.to_string(x)),{:createfriends2D,n,xc,yc}) end)
          true ->
            Enum.each(1..n,fn(x) -> GenServer.cast(String.to_atom(Integer.to_string(x)),{:createfriends,n,round(nth_root(3,n))}) end)
        end
    
        
       
    end
    def shutdown() do
      # Supervisor.stop(supervisor, reason \\ :normal, timeout \\ :infinity)
    end
    def handle_cast({:childterminate,x},state) do
    IO.puts "#{x} heard full rumor and stoped sending"
      Supervisor.terminate_child(String.to_atom("super"),String.to_atom(Integer.to_string(x) ))
    {:noreply, state}
  end
end
