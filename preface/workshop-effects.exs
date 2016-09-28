defmodule Effects do
  @moduledoc """
  This is a compact version of the "Effects" module. The complete code and
  documentation can be found in `effects.exs`.

  You do NOT need to edit this module.
  """
  defmodule Pure, do: defstruct [:value]
  defmodule Effect, do: defstruct [:effect, :next]
  def pure(val), do: %Pure{value: val}
  def effect(eff, next), do: %Effect{effect: eff, next: next}
  def bind(%Pure{value: val}, f), do: f.(val)
  def bind(%Effect{effect: e, next: n}, f), do: effect(e, &bind(n.(&1), f))
  def mv ~>> func, do: bind(mv, func)
end

defmodule PizzaService do
  @moduledoc """
  Service emulating an API you can use to order pizzas. In real life this
  would be a databse or a REST endpoint or similar.

  You do NOT need to edit this module.
  """

  # List of valid toppings for a pizza.
  @valid_toppings [
    :cheese,
    :pepperoni,
    :pineapple,
    :chicken,
    :ham,
    :peppers,
    :sausage,
    :onions
  ]

  use GenServer

  @doc """
  Handles `GenServer.call(:order, ...)`.
  """
  def handle_call({:order, toppings}, _from, {count, pizzas}) do
    IO.inspect({"[API] Trying to order pizza", toppings})
    # Sometimes ordering a pizza randomly fails because we're too busy.
    case 0..9 |> Enum.shuffle |> hd do
      # Life is good.
      value when value > 2 ->
        num_toppings = Enum.count(toppings)
        invalid_toppings = Enum.filter(
          toppings,
          fn topping -> !Enum.member?(@valid_toppings, topping) end
        )
        cond do
          # Invalid toppings.
          invalid_toppings == true ->
            {:reply, {:error, :invalid_toppings}, {count, pizzas}}
          # Too few toppings.
          num_toppings < 2 ->
            {:reply, {:error, :error_too_few_toppings}, {count, pizzas}}
          # Good number of toppings.
          true ->
            # Create the order.
            id = count
            order = %{id: id, toppings: toppings}
            # Respond with the order.
            {:reply, {:ok, id}, {count + 1, [order | pizzas]}}


        end
      # Life is not good.
      _ ->
        # Note that we're not available right now.
        {:reply, {:error, :error_service_busy}, {count, pizzas}}
    end
  end

  @doc """
  Handles `GenServer.call(:info, ...)`.
  """
  def handle_call({:info, id}, _from, {_, pizzas} = state) do
    # Try to find the order.
    case pizzas |> Enum.find(fn pizza -> pizza.id == id end) do
      # If not found, then return an error.
      nil -> {:reply, {:error, :no_such_order}, state}
      # If found, return the order.
      pizza -> {:reply, {:ok, pizza}, state}
    end
  end

  @doc """
  Handles `GenServer.call(:roulette, ...)`.
  """
  def handle_call({:roulette, count}, _from, state) do
    toppings = @valid_toppings |> Enum.take_random(count)
    {:reply, {:ok, toppings}, state}
  end

  @doc """
  Start the server and return a pid for it. If it's already running then just
  return the existing pid.
  """
  def init() do
    case GenServer.whereis(:pizza) do
      nil -> GenServer.start_link(PizzaService, {0, []}, name: :pizza)
      pid -> {:ok, pid}
    end
  end
end

defmodule Workshop do
  @moduledoc """
  This is the code you edit.
  """

  # Import the Effects module to be able to use `effect`, `pure` and `~>>`.
  import Effects

  defmodule RegularImplementation do
    @moduledoc """
    """

    defmodule API do
      @moduledoc """
      Service calls for pizza.
      """

      @doc """
      Order a pizza with the given toppings.
      """
      def order(toppings) do
        GenServer.call(:pizza, {:order, toppings})
      end

      def info(id) do
        GenServer.call(:pizza, {:info, id})
      end

      @doc """
      Get a certain number of random toppings.
      """
      def roulette(count) do
        GenServer.call(:pizza, {:roulette, count})
      end

      @doc """
      Order a random pizza.
      """
      def bake() do
        case API.roulette(5) do
          {:ok, toppings} ->
            case API.order(toppings) do
              {:ok, id} -> API.info(id)
              {:error, error} -> {:error, error}
            end
          {:error, error} -> {:error, error}
        end
      end
    end

    def run() do
      PizzaService.init()

      IO.puts "Regular API Order:"
      result = API.bake()
      IO.inspect result
    end
  end

  defmodule EffectImplementation do
    defmodule API do
      @moduledoc """
      TODO: Implement these functions using effects!

      For functions that call out to services:

      ```elixir
      effect(..., &pure/1)
      ```

      And for functions that use those services:

      ```elixir
      API.service(...) ~>> fn result -> ... end
      ```
      """

      def pizza(toppings) do
        nil # TODO: Implement me!
      end

      def info(id) do
        nil # TODO: Implement me!
      end

      def roulette(amount) do
        nil # TODO: Implement me!
      end

      def bake() do
        nil # TODO: Implement me!
      end
    end

    defmodule Interpreter do
      @moduledoc """
      TODO: Implement these functions to call real services!

      ```elixir
      def interpret(%Effects.Effect{
        effect: ...,
        next: next,
      }) do
        result = ...
        interpret(next.(result))
      end
      ```
      """
      def interpret(%Effects.Pure{value: value}) do
        nil # TODO: Implement me!
      end

      def interpret(%Effects.Effect{
        effect: {:order, toppings},
        next: next,
      }) do
        nil # TODO: Implement me!
      end

      def interpret(%Effects.Effect{
        effect: {:info, id},
        next: next,
      }) do
        nil # TODO: Implement me!
      end

      def interpret(%Effects.Effect{
        effect: {:roulette, count},
        next: next,
      }) do
        nil # TODO: Implement me!
      end
    end

    def run() do
      PizzaService.init()

      order = API.bake()
      IO.puts "Effect API Order:"
      IO.inspect Interpreter.interpret(order)
    end

    def bonus_1() do
      # Create an interpreter that manages error handling for you. This means
      # that the result from an effect is _always_ the real thing. The result
      # gives:
      # API.pizza([:cheese]) ~>> fn id -> id end
      # Instead of:
      # API.pizza([:cheese]) ~>> fn {:ok id} -> id end
      # This is incorporates some of the ideas of the maybe monad into the
      # interpreter itself. It means calling next.() only when no error has
      # occured.
    end

    def bonus_2() do
      # Create a test interpreter that returns mock values that you can use
      # for testing. This means being able to feed existing state into the
      # interpreter. You can do this by turning interpret/1 into interpret/2
      # where the first argument is the existing state.
    end
  end
end

IO.puts "**IMPORTANT** The real service CAN fail."
Workshop.RegularImplementation.run()
Workshop.EffectImplementation.run()
Workshop.EffectImplementation.bonus_1()
Workshop.EffectImplementation.bonus_2()
