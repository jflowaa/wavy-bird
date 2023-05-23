defmodule WavyBird.CodeNameGenerator.Server do
  use GenServer, restart: :transient
  require Logger

  def start_link(opts) do
    case GenServer.start_link(__MODULE__, opts, name: :code_name_generator_server) do
      {:ok, pid} ->
        {:ok, pid}

      {:error, {:already_started, _}} ->
        :ignore
    end
  end

  def init(_) do
    :ets.new(:nouns_table, [:set, :private, :named_table])
    :ets.new(:verbs_adjectives_table, [:set, :private, :named_table])

    File.stream!("data/nouns.txt")
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.with_index(1)
    |> Stream.each(fn x ->
      :ets.insert(:nouns_table, {elem(x, 1), elem(x, 0)})
    end)
    |> Stream.run()

    File.stream!("data/verbs.txt")
    |> Stream.concat(File.stream!("data/verbs.txt"))
    |> Stream.map(&String.trim_trailing/1)
    |> Stream.with_index(1)
    |> Stream.each(fn x ->
      :ets.insert(:verbs_adjectives_table, {elem(x, 1), elem(x, 0)})
    end)
    |> Stream.run()

    {:ok,
     {Keyword.get(:ets.info(:nouns_table), :size),
      Keyword.get(:ets.info(:verbs_adjectives_table), :size)}}
  end

  def handle_call(:generate, _from, state) do
    {:reply,
     {:ok,
      Enum.map(1..6, fn _ ->
        words = [
          :ets.lookup(:nouns_table, Enum.random(1..elem(state, 0)))
          |> hd
          |> elem(1)
          |> Macro.camelize(),
          :ets.lookup(:verbs_adjectives_table, Enum.random(1..elem(state, 1)))
          |> hd
          |> elem(1)
          |> Macro.camelize()
        ]

        "#{Enum.shuffle(words)}"
      end)}, state}
  end
end
