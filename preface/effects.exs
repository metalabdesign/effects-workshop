defmodule Effects do
  @moduledoc """
  A simple implementation of the Effect monad.
  """

  defmodule Pure do
    @moduledoc """

    """
    defstruct [:value]
  end

  defmodule Effect do
    @moduledoc """

    """
    defstruct [:effect, :next]
  end

  @doc """
  Create a new Pure from the given value.
  """
  def pure(value) do
    %Pure{value: value}
  end

  @doc """
  Create a new Effect.
  """
  def effect(effect, next) do
    %Effect{effect: effect, next: next}
  end

  @doc """

  """
  def bind(%Pure{value: val}, f) do
   f.(val)
  end

  @doc """

  """
  def bind(%Effect{effect: eff, next: next}, f) do
    effect(eff, &bind(next.(&1), f))
  end

  @doc """
  Infix operator for invoking `bind`. This just makes chaining `bind` operations
  together all-around more pleasant.
  """
  def mv ~>> func do
    bind(mv, func)
  end
end

defmodule Effects.Example do
  import Effects

  defmodule Interpreter do
    # Simple interpreter.
    def interpret(%Effects.Pure{value: val}) do
      val
    end
    def interpret(%Effects.Effect{effect: :all_tweets, next: next}) do
      interpret(next.([%{user: "bob"}]))
    end
  end

  def run do
    # Creating instances of Effects types.
    IO.inspect({"5 -> ", pure(5)})
    IO.inspect({"ALL_TWEETS -> ", effect(:all_tweets, &pure/1)})

    # Using monadic chaining.
    check = fn user -> fn tweets -> pure(
      Enum.any?(
        tweets,
        fn tweet -> tweet.user == user end
      )
    ) end end

    # Pure values, things happen immediately!
    IO.inspect(pure([%{user: "bob"}]) ~>> check.("bob"))
    # Effects are deferred until...
    IO.inspect(effect(:all_tweets, &pure/1) ~>> check.("bob"))

    # You interpret them!
    IO.inspect(interpret(effect(:all_tweets, &pure/1) ~>> check.("bob")))
    IO.inspect(interpret(effect(:all_tweets, &pure/1) ~>> check.("carl")))
  end

  defp interpret(eff) do
    Interpreter.interpret(eff)
  end

end

Effects.Example.run
