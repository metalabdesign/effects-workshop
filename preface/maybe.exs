defmodule Maybe do
  @moduledoc """
  A simple implementation of the Maybe monad.
  """

  defmodule Just do
    @moduledoc """

    """
    defstruct [:value]
  end

  defmodule Nothing do
    @moduledoc """

    """
    defstruct []
  end

  @doc """

  """
  def return(val) when is_nil(val) do
    %Nothing{}
  end

  @doc """

  """
  def return(val) do
    %Just{value: val}
  end

  @doc """

  """
  def bind(%Just{value: value}, func) do
    apply(func, [value])
  end

  @doc """

  """
  def bind(%Nothing{}, _) do
    %Nothing{}
  end

  @doc """
  Infix operator for invoking `bind`. This just makes chaining `bind` operations
  together all-around more pleasant.
  """
  def mv ~>> func do
    bind(mv, func)
  end
end

defmodule Maybe.Example do
  import Maybe
  def run do
    # Creating instances of Maybe types.
    IO.inspect({"nil -> ", return(nil)})
    IO.inspect({"5 -> ", return(5)})

    # Using monadic chaining.
    double = fn val -> return(val * 2) end
    increment = fn val -> return(val + 1) end
    half = fn
      val when rem(val, 2) == 0 -> return(val / 2)
      _ -> return(nil)
    end

    IO.inspect({"8 / 2 + 1 -> ", return(8) ~>> half ~>> increment})
    IO.inspect({"9 / 2 + 1 -> ", return(9) ~>> half ~>> increment})
  end
end

Maybe.Example.run
