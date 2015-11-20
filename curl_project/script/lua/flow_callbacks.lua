ProjectFlowCallbacks = ProjectFlowCallbacks or {}

-- Example custom project flow node callback. Prints a message.
-- The parameter t contains the node inputs, and node outputs can
-- be set on t. See documentation for details.
function ProjectFlowCallbacks.example(t)
	local message = t.Text or ""
	print("Example Node Message: " .. message)
end
