defmodule ArlixContract do

	def run_contract(owner, "steal_it", %{} = _input, %{"hands" => hands, "owner" => _last_owner} = state) do
		{:ok, %{"hands" => hands+1, "owner" => owner}}
	end

	def run_contract(_owner, _method, _input, _state) do
	 	{:error, "Nothing to see here"}
	end

end
