do
	local os_time = os.time
	os.difftime2 = function(time)
		return os_time() - time
	end
end