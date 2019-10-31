defmodule Proj2 do
    def shutdown() do
        shutdown()
    end

    def main(args) do
      n=Enum.at(args,0)
      topo=Enum.at(args,1)
      algo=Enum.at(args,2)
    #   IO.puts "topo is #{inspect(topo)} algo is #{inspect(algo)}"
      Gossip.start_link(n,topo,algo)
    #   Gossip.startchild()
      shutdown()
end
end

# Proj2.mainfun(System.argv())