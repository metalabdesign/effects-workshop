defmodule Effects do
  @moduledoc """
  This is a compact version of the "Effects" module. The complete code and
  documentation can be found in `effects.exs`.
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
  """
  use GenServer
  defp rand(seed), do: rem(seed * 1103515245 + 12345, 2147483648)
  defp rand(seed, max), do: {rand(seed), rem(rand(seed), max)}

  def handle_call({:order, toppings}, _from, {count, pizzas, seed}) do
    # Sometimes ordering a pizza randomly fails because we're too busy.
    case rand(seed, 10) do
      # Life is good.
      {seed, value} when value > 2 ->
        # Check we have an OK number of toppings
        case Enum.count(toppings) do
          # Good number of toppings.
          num_toppings when num_toppings > 2 ->
            # Create the order.
            order = %{id: count, toppings: toppings}
            # Respond with the order.
            {:reply, {:ok, order}, {count + 1, [order | pizzas], seed}}
          # Too few toppings.
          _ ->
            {:reply, {:error, :error_too_few_toppings}, {count, pizzas, seed}}
        end
      # Life is not good.
      {seed, _} ->
        # Note that we're not available right now.
        {:reply, {:error, :error_service_busy}, {count, pizzas, seed}}
    end
  end

  def handle_call({:info, id}, _from, {_, pizzas, _} = state) do
    # Try to find the order.
    case pizzas |> Enum.find(fn pizza -> pizza.id == id end) do
      # If not found, then return an error.
      nil -> {:reply, {:error, :no_such_order}, state}
      # If found, return the order.
      pizza -> {:reply, {:ok, pizza}, state}
    end
  end

  def init() do
    case GenServer.whereis(:pizza) do
      nil -> GenServer.start_link(PizzaService, {0, [], 12345}, name: :pizza)
      pid -> {:ok, pid}
    end
  end
end

"""
Tasks:?!?!?!
 * Refactor existing API to use effects.
  * Change side-effecting API to return effect objects.
  * Create interpreter that calls out to the real service.
 * Add test interpreter
"""

defmodule Workshop do
  @moduledoc """

  """
  
  defmodule RegularImplementation do
    @moduledoc """

    """
    
    defmodule RegularAPI do
      @moduledoc """

      """
      def order(toppings) do
        GenServer.call(:pizza, {:order, toppings})
      end

      def info(id) do
        GenServer.call(:pizza, {:info, id})
      end
    end
    
    def run() do
      PizzaService.init()

      orderResponse = RegularAPI.order([:cheese, :ham, :pineapple])
      orderId = elem(orderResponse, 1)[:id]

      RegularAPI.info(orderId)
    end
  end
  
  defmodule EffectImplementation do
    defmodule EffectAPI do
      import Effects
      def pizza(toppings) do
        effect({:order, toppings}, &pure/1)
      end

      def info(id) do
        effect({:info, id}, &pure/1)
      end
    end
    
    defmodule Interpreter do
      def interpret(%Effects.Pure{value: value}) do
        value
      end
      
      def interpret(%Effects.Effect{
        effect: {:order, toppings},
        next: next,
      } = effect) do
        result = GenServer.call(:pizza, {:order, toppings})
        interpret(next.(result))
      end
      
      def interpret(%Effects.Effect{
        effect: {:info, id},
        next: next,
      }) do
        result = GenServer.call(:pizza, {:info, id})
        interpret(next.(result))
      end
    end
    
    def run() do
      PizzaService.init()
      program = EffectAPI.pizza([:cheese, :ham, :pineapple])
      Interpreter.interpret(program)
    end
  end
  
  defmodule EffectImplementationTest do
    defmodule TestInterpreter do
      def interpret(_, %Effects.Pure{value: value}) do
        value
      end
      
      def interpret({pizzas}, %Effects.Effect{
        effect: {:order, toppings},
        next: next,
      }) do
        result = %{id: Enum.count(pizzas), toppings: toppings}
        interpret({[result|pizzas]}, next.(result))
      end
      
      def interpret({pizzas} = state, %Effects.Effect{
        effect: {:info, id},
        next: next,
      }) do
        case Enum.find(pizzas, fn pizza -> pizza.id == id end) do
          nil -> interpret(state, next.({:error, :no_such_order}))
          order -> interpret(state, next.({:ok, order}))
        end
      end
    end
    
    def test() do
      import ExUnit.Assertions

      # Test order fetching
      order = %{id: 5, toppings: [:cheese]}
      orders = [order]
      state = {orders}
      result = TestInterpreter.interpret(state, EffectAPI.info(5))
      assert(result == {:ok, order}, "Expected pizza.")
      result = TestInterpreter.interpret(state, EffectAPI.info(0))
      assert(result == {:error, :no_such_order}, "Expected error.")
    end
  end
end
