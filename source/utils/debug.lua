do
	local time = os.time
	debug.measure = function(f, ...)
		local t = time()
		f(...)
		printf("%d ms", time() - t)
	end
	
	debug.pmeasure = function(text, f, ...)
		local t = time()
		f(...)
		printf(text, ("%d ms"):format(time() - t))
	end
end