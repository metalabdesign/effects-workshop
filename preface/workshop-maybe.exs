defmodule RecordService do
  def new_record(name, email, age) do
    %{name: name, email: email, age: age}
  end

  def set_name(%{email: email, age: age}, newName) do
    %{name: newName, email: email, age: age}
  end
  
  def set_email(%{name: name, age: age}, newEmail) do
    %{name: name, email: newEmail, age: age}
  end

  def set_age(%{name: name, email: email, age: age}, newAge) when newAge >= age do
    %{name: name, email: email, age: newAge}
  end

  def set_age(_, _) do
    nil
  end

  def print(%{name: name, email: email, age: age}) do
    IO.puts "------------------------------"
    IO.puts Enum.join(["Name:", name], "")
    IO.puts Enum.join(["Email:", email], "")
    IO.puts Enum.join(["Age:", age], "")
    IO.puts "------------------------------"
  end
end

# Normal implementation
rec = RecordService.new_record("Billy", "billy@metalab.co", 31)
rec = RecordService.set_age(rec, 20)
if rec != nil do
  rec = RecordService.set_name(rec, "Billy He")
  rec = RecordService.set_email(rec, "billy@metalabdesign.com")
  RecordService.print(rec)
end
